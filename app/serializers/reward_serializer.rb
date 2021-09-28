# frozen_string_literal: true

class RewardSerializer < ApplicationSerializer
  attributes :id,
             :points,
             :quantity,
             :title,
             :description,
             :image,
             :image_url,
             :is_active,
             :deleted_at,
             :created_at,
             :updated_at,
             :created_by,
             :user_rewards

  def user_rewards
    object.user_rewards
  end

  def created_by
    object.created_by
  end
end
