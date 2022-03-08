# frozen_string_literal: true

module DiscourseRewards
  class Campaign < ActiveRecord::Base
    self.table_name = 'discourse_rewards_campaigns'

    belongs_to :created_by, class_name: 'User'
  end
end
