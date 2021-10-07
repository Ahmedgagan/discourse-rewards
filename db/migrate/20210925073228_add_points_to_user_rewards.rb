# frozen_string_literal: true
class AddPointsToUserRewards < ActiveRecord::Migration[6.1]
  def change
    add_column :discourse_rewards_user_rewards, :points, :integer
  end
end
