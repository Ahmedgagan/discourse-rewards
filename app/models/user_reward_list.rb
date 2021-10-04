# frozen_string_literal: true

# view model for user badges
module DiscourseRewards
  class UserRewardList
    alias :read_attribute_for_serialization :send

    attr_accessor :user_rewards, :count

    def initialize(opts = {})
      @user_rewards = opts[:user_rewards]
      @count = opts[:count]
    end
  end
end
