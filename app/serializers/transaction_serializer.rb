# frozen_string_literal: true

class TransactionSerializer < ApplicationSerializer
  attributes :user_reward,
             :user,
             :user_point,
             :created_at,
             :reward_points,
             :user_points_category

  def user_reward
    UserRewardSerializer.new(DiscourseRewards::UserReward.find(object.user_reward_id)).as_json if object.user_reward_id
  end

  def user
    User.find(object.user_id) if object.user_id
  end

  def user_point
    DiscourseRewards::UserPoint.find(object.point_id) if object.point_id
  end

  def user_points_category
    DiscourseRewards::UserPointsCategory.find(object.user_points_category_id) if object.user_points_category_id
  end
end
