class AddImageUrlToRewards < ActiveRecord::Migration[6.1]
  def change
    add_column :discourse_rewards_rewards, :image_url, :string
  end
end
