# frozen_string_literal: true

# name: discourse-rewards
# about: Gives points to user and allows user to redeem their points with available rewards
# version: 0.1
# author: Ahmed Gagan
# url: https://github.com/Ahmedgagan/discourse-rewards

enabled_site_setting :discourse_rewards_enabled

register_asset 'stylesheets/rewards.scss'
register_asset 'stylesheets/mobile/rewards.scss', :mobile

if respond_to?(:register_svg_icon)
  register_svg_icon "fas fa-trophy"
  register_svg_icon "fas fa-gift"
end

after_initialize do
  SeedFu.fixture_paths << Rails.root.join("plugins", "discourse-rewards", "db", "fixtures").to_s
  UploadSecurity.register_custom_public_type("reward_image")
  Notification::types[:rewards] = 3190123 # a random number to avoid conflicts

  module ::DiscourseRewards
    PLUGIN_NAME ||= 'discourse-rewards'

    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseRewards
    end
  end

  require_dependency 'user_summary'
  class ::UserSummary
    def total_earned_points
      @user.user_points.sum(:reward_points)
    end
  end

  require_dependency 'user_summary_serializer'
  class ::UserSummarySerializer
    attributes :total_earned_points

    def total_earned_points
      object.total_earned_points
    end
  end

  [
    "../app/serializers/reward_serializer.rb",
    "../app/serializers/user_reward_serializer.rb",
    "../app/serializers/reward_list_serializer.rb",
    "../app/serializers/user_reward_list_serializer.rb",
    "../app/serializers/transaction_serializer.rb",
    "../lib/discourse-rewards/non_anonymous_user_constraint.rb",
    "../lib/discourse-rewards/user_extension.rb",
    "../lib/discourse-rewards/rewards.rb",
    "../lib/discourse-rewards/reward_notification.rb",
    "../app/models/user_reward.rb",
    "../app/controllers/rewards_controller.rb",
    "../app/models/reward.rb",
    "../app/models/user_point.rb",
    "../app/models/reward_list.rb",
    "../app/models/user_reward_list.rb",
    "../app/models/transaction.rb",
    "../app/models/user_points_category.rb",
    "../jobs/scheduled/grant_active_member_bronze_badges",
    "../jobs/scheduled/grant_active_member_silver_badges",
    "../jobs/scheduled/grant_active_member_gold_badges",
    "../jobs/scheduled/grant_best_liked_in_a_month_badges",
    "../jobs/scheduled/grant_conversation_maker_badges",
    "../jobs/scheduled/grant_embassador_badges",
    "../config/routes"
  ].each { |path| require File.expand_path(path, __FILE__) }

  reloadable_patch do |plugin|
    User.class_eval { prepend DiscourseRewards::UserExtension }
  end

  module UserClassMethods
    def create_visit_record!(date, opts = {})
      super
      points = SiteSetting.discourse_rewards_points_for_daily_login.to_i
      description = {
        type: 'daily_login',
        date: Date.today
      }

      DiscourseRewards::UserPoint.create(user_id: self.id, user_points_category_id: 3, reward_points: points, description: description.to_json) if points > 0
    end
  end

  User.prepend UserClassMethods if SiteSetting.discourse_rewards_enabled

  Discourse::Application.routes.append do
    mount ::DiscourseRewards::Engine, at: '/'
    get "rewards" => "groups#index"
  end

  add_to_class(:user, :total_earned_points) do
    self.user_points.sum(:reward_points)
  end

  add_to_class(:user, :available_points) do
    self.total_earned_points - self.user_rewards.sum(:points)
  end

  add_to_class(:user, :rewards) do
    DiscourseRewards::Reward.where(created_by_id: self.id)
  end

  add_to_serializer(:basic_user, :total_earned_points) do
    user&.total_earned_points
  end

  add_to_serializer(:basic_user, :available_points) do
    user&.available_points
  end

  add_to_serializer(:current_user, :total_earned_points) do
    scope.user.total_earned_points
  end

  add_to_serializer(:current_user, :available_points) do
    scope.user.available_points
  end

  add_to_serializer(:current_user, :user_rewards) do
    scope.user.user_rewards
  end

  add_to_serializer(:current_user, :rewards) do
    scope.user.rewards
  end

  Site.preloaded_category_custom_fields << "rewards_points_for_topic_create"

  on(:notification_created) do |notification|
    data = JSON.parse(notification.data).with_indifferent_access

    badge = Badge.find(data[:badge_id]) if notification.notification_type == Notification.types[:granted_badge]

    if badge && badge.badge_grouping_id == 6
      user_badge = UserBadge.where(user_id: notification.user_id, badge_id: data[:badge_id]).order(created_at: :desc).first

      points = 0

      if badge.badge_type_id == BadgeType::Bronze
        points = SiteSetting.discourse_rewards_points_for_bronze_badges.to_i
      elsif badge.badge_type_id == BadgeType::Silver
        points = SiteSetting.discourse_rewards_points_for_silver_badges.to_i
      elsif badge.badge_type_id == BadgeType::Gold
        points = SiteSetting.discourse_rewards_points_for_gold_badges.to_i
      end

      description = {
        type: 'badge',
        badge_id: badge.id,
        name: badge.name
      }
      DiscourseRewards::UserPoint.create(user_id: notification.user_id, user_points_category_id: 1, user_badge_id: user_badge.id, reward_points: points, description: description.to_json) if points > 0

      user_message = {
        available_points: user_badge.user.available_points
      }

      MessageBus.publish("/u/#{user_badge.user.id}/rewards", user_message)
    end
  end

  on(:post_created) do |post|
    if post.user_id > 0 && post.post_number > 1 && !post.topic.archetype == Archetype.private_message
      top_posts = Post.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
        .where(user_id: post.user_id)
        .where("post_number > 1")
        .order(:created_at)
        .limit(SiteSetting.discourse_rewards_daily_top_replies_to_grant_points.to_i)
        .pluck(:id) if SiteSetting.discourse_rewards_daily_top_replies_to_grant_points.to_i > 0

      if !top_posts || top_posts.include?(post.id)
        points = SiteSetting.discourse_rewards_points_for_post_create.to_i

        user = User.find(post.user_id)

        description = {
          type: 'post',
          post_id: post.id,
          post_number: post.post_number,
          topic_slug: post.topic.slug,
          topic_id: post.topic.id,
          topic_title: post.topic.title
        }

        DiscourseRewards::UserPoint.create(user_id: post.user_id, user_points_category_id: 4, reward_points: points, description: description.to_json) if points > 0

        user_message = {
          available_points: post.user.available_points,
          points: post.user.total_earned_points
        }

        MessageBus.publish("/u/#{post.user_id}/rewards", user_message)
      end
    end
  end

  on(:topic_created) do |topic|
    if topic.user_id > 0 && !topic.archetype == Archetype.private_message
      top_topics = Topic.where(created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
        .where(user_id: topic.user_id)
        .order(:created_at)
        .limit(SiteSetting.discourse_rewards_daily_top_topics_to_grant_points.to_i)
        .pluck(:id) if SiteSetting.discourse_rewards_daily_top_topics_to_grant_points.to_i > 0

      if !top_topics || top_topics.include?(topic.id)
        points = topic.category.custom_fields['rewards_points_for_topic_create'].to_i

        points = SiteSetting.discourse_rewards_points_for_topic_create.to_i if points <= 0

        user = User.find(topic.user_id)

        description = {
          type: 'topic',
          post_number: 1,
          topic_slug: topic.slug,
          topic_id: topic.id,
          topic_title: topic.title
        }

        DiscourseRewards::UserPoint.create(user_id: topic.user_id, user_points_category_id: 4, reward_points: points, description: description.to_json) if points > 0

        user_message = {
          available_points: topic.user.available_points
        }

        MessageBus.publish("/u/#{topic.user_id}/rewards", user_message)
      end
    end
  end

  on(:like_created) do |like|
    points = SiteSetting.discourse_rewards_points_for_like_received.to_i
    post = Post.find(like.post_id)
    user = post.user

    if user.id > 0
      top_likes = PostAction.where(post_action_type_id: PostActionType.types[:like])
        .where(post_id: Post.where(user_id: user.id), created_at: Time.zone.now.beginning_of_day..Time.zone.now.end_of_day)
        .order(:created_at)
        .limit(SiteSetting.discourse_rewards_daily_top_like_received_to_grant_points.to_i)
        .pluck(:id) if SiteSetting.discourse_rewards_daily_top_like_received_to_grant_points.to_i > 0

      if !top_likes || top_likes.include?(like.id)
        description = {
          type: 'like',
          post_id: post.id,
          post_number: post.post_number,
          topic_id: post.topic.id,
          topic_slug: post.topic.slug,
          topic_title: post.topic.title
        }

        DiscourseRewards::UserPoint.create(user_id: user.id, user_points_category_id: 4, reward_points: points, description: description.to_json) if points > 0

        user_message = {
          available_points: user.available_points
        }

        MessageBus.publish("/u/#{user.id}/rewards", user_message)
      end
    end
  end
end
