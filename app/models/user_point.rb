# frozen_string_literal: true

module DiscourseRewards
  class UserPoint < ActiveRecord::Base
    self.table_name = 'discourse_rewards_user_points'

    belongs_to :user
    belongs_to :user_badge
    belongs_to :user_points_category

    def self.user_total_points(user)
      UserPoint.where(user_id: user.id).sum(:reward_points)
    end
  end
end
