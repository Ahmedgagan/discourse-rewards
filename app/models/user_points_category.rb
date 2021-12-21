# frozen_string_literal: true

module DiscourseRewards
  class UserPointsCategory < ActiveRecord::Base
    self.table_name = 'discourse_rewards_user_points_categories'

    has_many :user_points
  end
end
