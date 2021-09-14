# frozen_string_literal: true
class CreateDiscourseRewardsRedemeedPoints < ActiveRecord::Migration[6.1]
  def change
    create_table :discourse_rewards_redemeed_points do |t|
      t.integer :user_id
      t.integer :points
      t.timestamps
    end
  end
end
