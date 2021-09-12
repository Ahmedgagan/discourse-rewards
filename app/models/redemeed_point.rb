# frozen_string_literal: true

module DiscourseRewards
  class RedemeedPoint < ActiveRecord::Base
    self.table_name = 'discourse_rewards_redemeed_points'

    belongs_to :user
  end
end
