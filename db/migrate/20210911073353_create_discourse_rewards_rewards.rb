# frozen_string_literal: true
class CreateDiscourseRewardsRewards < ActiveRecord::Migration[6.1]
  def change
    create_table :discourse_rewards_rewards do |t|
      t.integer :uploaded_by, null: false
      t.integer :points, null: false
      t.integer :quantity, null: false
      t.string :title, null: false
      t.string :description
      t.string :image
      t.boolean :is_active, default: true, null: false
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
