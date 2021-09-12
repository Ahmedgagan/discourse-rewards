# frozen_string_literal: true

module DiscourseRewards
  class Reward < ActiveRecord::Base
    self.table_name = 'discourse_rewards_rewards'

    has_many :rewards

    default_scope { where(deleted_at: nil) }
  end
end
