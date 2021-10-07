# frozen_string_literal: true

class UserRewardSerializer < ApplicationSerializer
  attributes :id,
             :points,
             :status,
             :created_at,
             :updated_at

  has_one :reward, serializer: RewardSerializer, embed: :object
  has_one :user, serializer: BasicUserSerializer, embed: :objects
end
