# frozen_string_literal: true

module DiscourseRewards
  class UserReward < ActiveRecord::Base
    self.table_name = 'discourse_rewards_user_rewards'

    belongs_to :user
    belongs_to :reward

    enum status: [:applied, :granted]
  end
end
