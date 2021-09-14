# frozen_string_literal: true

# name: discourse-rewards
# about: Gives points to user and allows user to redeem their points with available rewards
# version: 0.1
# author: Ahmed Gagan
# url: https://github.com/Ahmedgagan/discourse-rewards

enabled_site_setting :discourse_rewards_enabled

CUSTOM_BADGES = ['Embassador', 'Best liked in a month', 'Conversation Maker', 'Active Member', 'Wiki Master']

after_initialize do
  SeedFu.fixture_paths << Rails.root.join("plugins", "discourse-rewards", "db", "fixtures").to_s

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
    "../lib/discourse-rewards/user_extension.rb",
    "../app/models/user_reward.rb",
    "../app/models/redemeed_point.rb",
    "../app/controllers/rewards_controller.rb",
    "../app/models/reward.rb",
    "../app/models/user_point.rb",
    "../jobs/scheduled/grant_active_member_badges",
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
  end

  add_to_serializer(:current_user, :total_earned_points) do
    scope.user.user_points.sum(:reward_points)
  end

  on(:notification_created) do |notification|
    if notification.notification_type == Notification.types[:granted_badge] && CUSTOM_BADGES.include?(JSON.parse(notification.data).with_indifferent_access[:badge_name])
      data = JSON.parse(notification.data).with_indifferent_access

      user_badge = UserBadge.where(user_id: notification.user_id, badge_id: data[:badge_id]).order(created_at: :desc).first

      DiscourseRewards::UserPoint.create(user_id: notification.user_id, user_badge_id: user_badge.id, reward_points: 200)
    end
  end
end
