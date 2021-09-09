# frozen_string_literal: true

module DiscourseRewards::UserExtension
  def self.prepended(base)
    base.has_many :user_points, class_name: 'DiscourseRewards::UserPoint'
  end
end
