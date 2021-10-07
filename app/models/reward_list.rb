# frozen_string_literal: true

# view model for user badges
module DiscourseRewards
  class RewardList
    alias :read_attribute_for_serialization :send

    attr_accessor :rewards, :count

    def initialize(opts = {})
      @rewards = opts[:rewards]
      @count = opts[:count]
    end
  end
end
