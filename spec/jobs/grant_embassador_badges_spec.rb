# frozen_string_literal: true

require 'rails_helper'

describe Jobs::GrantEmbassadorBadges do
  let(:granter) { described_class.new }

  it "awards the best liked in a month badge" do
    invited_user = Fabricate(:invited_user)
    invited_user1 = Fabricate(:invited_user)
    invited_user2 = Fabricate(:invited_user)

    invited_user.user.update!(
      trust_level: 2
    )

    invited_user1.user.update!(
      trust_level: 2
    )

    invited_user2.user.update!(
      trust_level: 2
    )

    granter.execute({})

    freeze_time(Time.zone.now + 11.minutes)

    badge = invited_user.user.user_badges.where(badge_id: Badge.find_by(name: 'Embassador').id)
    expect(badge.count).to eq(1)
    expect(invited_user.user.user_points.sum(:reward_points)).to be(SiteSetting.discourse_rewards_points_for_bronze_badges)

    badge = invited_user1.user.user_badges.where(badge_id: Badge.find_by(name: 'Embassador').id)
    expect(badge.count).to eq(1)
    expect(invited_user1.user.user_points.sum(:reward_points)).to be(SiteSetting.discourse_rewards_points_for_bronze_badges)

    badge = invited_user2.user.user_badges.where(badge_id: Badge.find_by(name: 'Embassador').id)
    expect(badge.count).to eq(1)
    expect(invited_user2.user.user_points.sum(:reward_points)).to be(SiteSetting.discourse_rewards_points_for_bronze_badges)
  end
end
