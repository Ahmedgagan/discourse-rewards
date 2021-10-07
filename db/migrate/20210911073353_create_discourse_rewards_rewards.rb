# frozen_string_literal: true
class CreateDiscourseRewardsRewards < ActiveRecord::Migration[6.1]
  def change
    create_table :discourse_rewards_rewards do |t|
      t.integer :created_by_id, null: false
      t.integer :points, null: false
      t.integer :quantity, null: false
      t.string :title, null: false
      t.text :description, null: false
      t.integer :upload_id
      t.string :upload_url
      t.boolean :is_active, default: true, null: false
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
