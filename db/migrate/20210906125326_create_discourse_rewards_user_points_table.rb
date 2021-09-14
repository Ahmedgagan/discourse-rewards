# frozen_string_literal: true
class CreateDiscourseRewardsUserPointsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :discourse_rewards_user_points do |t|
      t.integer :user_id
      t.integer :user_badge_id, unique: true
      t.integer :reward_points
      t.timestamps
    end
  end
end
