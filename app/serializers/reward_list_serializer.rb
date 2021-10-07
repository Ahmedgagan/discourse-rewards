# frozen_string_literal: true

class RewardListSerializer < ApplicationSerializer
  has_many :rewards, serializer: RewardSerializer, embed: :object
  attributes :count
end
