# frozen_string_literal: true

require 'rails_helper'

describe Jobs::GrantConversationMakerBadges do

  let(:granter) { described_class.new }

  it "awards the best liked in a month badge" do
    user = Fabricate(:user)
    user1 = Fabricate(:user)
    user2 = Fabricate(:user)
    user3 = Fabricate(:user)
    user4 = Fabricate(:user)

    topic = Fabricate(:topic, user: user)
    topic1 = Fabricate(:topic, user: user1)

    post = Fabricate(:post, user: user2, topic: topic)
    post1 = Fabricate(:post, user: user3, topic: topic)
    post2 = Fabricate(:post, user: user4, topic: topic1)

    freeze_time = 1.month.from_now.beginning_of_month - Time.zone.now

    freeze_time(Time.zone.now + freeze_time)

    granter.execute({})

    freeze_time(Time.zone.now + 11.minutes)

    badge = user.user_badges.where(badge_id: Badge.find_by(name: 'Conversation Maker').id)
    expect(badge.count).to eq(1)

    expect(user.user_points.sum(:reward_points)).to be(SiteSetting.discourse_rewards_points_for_bronze_badges)
  end
end
