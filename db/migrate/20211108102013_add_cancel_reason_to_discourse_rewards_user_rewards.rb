# frozen_string_literal: true
class AddCancelReasonToDiscourseRewardsUserRewards < ActiveRecord::Migration[6.1]
  def change
    add_column :discourse_rewards_user_rewards, :cancel_reason, :text
  end
end
