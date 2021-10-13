# frozen_string_literal: true
class AddDescriptionToUserPoints < ActiveRecord::Migration[6.1]
  def change
    add_column :discourse_rewards_user_points, :description, :string
  end
end
