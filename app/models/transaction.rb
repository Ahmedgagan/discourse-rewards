# frozen_string_literal: true

# view model for user badges
module DiscourseRewards
  class Transaction
    alias :read_attribute_for_serialization :send

    attr_accessor :user_id, :user_reward_id, :user_points_category_id, :point_id, :reward_points, :created_at

    def initialize(opts = {})
      @user_id = opts[:user_id]
      @user_reward_id = opts[:user_reward_id]
      @user_points_category_id = opts[:user_points_category_id]
      @point_id = opts[:point_id]
      @reward_points = opts[:reward_points]
      @created_at = opts[:created_at]
    end
  end
end
