# frozen_string_literal: true
class CreateDiscourseRewardsUserPointsCategoryTable < ActiveRecord::Migration[6.1]
  def change
    create_table :discourse_rewards_user_points_categories do |t|
      t.string :name, unique: true
      t.string :slug, unique: true
      t.text :description, unique: true
      t.timestamps
    end
  end
end
