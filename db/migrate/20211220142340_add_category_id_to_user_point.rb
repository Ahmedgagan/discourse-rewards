# frozen_string_literal: true
class AddCategoryIdToUserPoint < ActiveRecord::Migration[6.1]
  def change
    add_column :discourse_rewards_user_points, :user_points_category_id, :integer
  end
end
