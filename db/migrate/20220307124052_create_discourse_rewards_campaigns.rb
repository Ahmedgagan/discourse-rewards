# frozen_string_literal: true
class CreateDiscourseRewardsCampaigns < ActiveRecord::Migration[6.1]
  def change
    create_table :discourse_rewards_campaigns do |t|
      t.string :name
      t.text :description
      t.date :start_date
      t.date :end_date
      t.jsonb :include_parameters
      t.integer :created_by_id, null: false
      t.timestamps
    end
  end
end
