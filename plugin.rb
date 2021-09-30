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
end

after_initialize do
  SeedFu.fixture_paths << Rails.root.join("plugins", "discourse-rewards", "db", "fixtures").to_s
  UploadSecurity.register_custom_public_type("reward_image")

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
    "../lib/discourse-rewards/user_extension.rb",
    "../app/models/user_reward.rb",
    "../app/models/redemeed_point.rb",
    "../app/controllers/rewards_controller.rb",
    "../app/models/reward.rb",
    "../app/models/user_point.rb",
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
    scope.user.total_earned_points
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

  on(:notification_created) do |notification|
    data = JSON.parse(notification.data).with_indifferent_access

    badge = Badge.find(data[:badge_id]) if notification.notification_type == Notification.types[:granted_badge]

    if badge && badge.badge_grouping_id == 6
      user_badge = UserBadge.where(user_id: notification.user_id, badge_id: data[:badge_id]).order(created_at: :desc).first

      points = 0

      if badge.badge_type_id == BadgeType::Bronze
        points = SiteSetting.discourse_rewards_points_for_bronze_badges
      elsif badge.badge_type_id == BadgeType::Silver
        points = SiteSetting.discourse_rewards_points_for_silver_badges
      elsif badge.badge_type_id == BadgeType::Gold
        points = SiteSetting.discourse_rewards_points_for_gold_badges
      end

      DiscourseRewards::UserPoint.create(user_id: notification.user_id, user_badge_id: user_badge.id, reward_points: points) if points > 0
    end
  end
end
