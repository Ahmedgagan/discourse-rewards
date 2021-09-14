# frozen_string_literal: true
class CreateDiscourseRewardsUserRewards < ActiveRecord::Migration[6.1]
  def change
    create_table :discourse_rewards_user_rewards do |t|
      t.integer :user_id
      t.integer :status, default: 0, null: false
      t.integer :reward_id
      t.timestamps
    end
  end
end
