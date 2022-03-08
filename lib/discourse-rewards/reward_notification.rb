# frozen_string_literal: true

module DiscourseRewards
  class RewardNotification
    def initialize(reward, user, type)
      @reward = reward
      @user = user
      @type = type
    end

    def self.types
      @types ||= Enum.new(redeemed: "redeemed", new: "new")
    end

    def get_type
      types
    end

    def create
      if @type == DiscourseRewards::RewardNotification.types[:redeemed]
        User.joins(:group_users).where("group_users.group_id=?", Group::AUTO_GROUPS[:admins]).find_each do |user|
          Notification.create!(
            user_id: user.id,
            notification_type: Notification.types[:rewards],
            data: {
              display_username: @user.username,
              user_reward: true,
              reward: @reward,
              type: DiscourseRewards::RewardNotification.types[:redeemed]
            }.to_json
          )
        end
      elsif @type == DiscourseRewards::RewardNotification.types[:new]
        User.where(silenced_till: nil, suspended_till: nil, active: true).where.not(id: @user.id).where("id NOT IN (SELECT user_id FROM anonymous_users)").find_each do |user|
          Notification.create!(
            user_id: user.id,
            notification_type: Notification.types[:rewards],
            data: {
              display_username: @user.username,
              user_reward: true,
              reward: @reward,
              type: DiscourseRewards::RewardNotification.types[:new]
            }.to_json
          )
        end
      end
    end
  end
end
