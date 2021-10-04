# frozen_string_literal: true

class UserRewardListSerializer < ApplicationSerializer
  has_many :user_rewards, serializer: UserRewardSerializer, embed: :object
  attributes :count
end
