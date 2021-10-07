# frozen_string_literal: true

module DiscourseRewards
  class Reward < ActiveRecord::Base
    self.table_name = 'discourse_rewards_rewards'

    has_many :user_rewards
    belongs_to :created_by, class_name: 'User'

    default_scope { where(deleted_at: nil) }
  end
end
