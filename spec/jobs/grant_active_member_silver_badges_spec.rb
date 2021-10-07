# frozen_string_literal: true

require 'rails_helper'

def badge(user)
  user.user_badges.where(badge_id: Badge.find_by(name: 'Obsessed').id)
end

describe Jobs::GrantActiveMemberSilverBadges do
  let(:granter) { described_class.new }

  it "doesn't award to a user who is not an invited_user" do
    user = Fabricate(:user, created_at: 1.month.ago)

    granter.execute({})

    expect(badge(user)).to be_blank
  end

  it "doesn't award to a invited_user who is less than 6 months old" do
    invited_user = Fabricate(:invited_user, created_at: 1.month.ago)

    granter.execute({})

    expect(badge(invited_user.user)).to be_blank
  end

  it "doesn't award to a invited_user with less than 12 visited days" do
    invited_user = Fabricate(:invited_user, created_at: 200.days.ago)

    invited_user.user.update!(
      created_at: 200.days.ago
    )

    granter.execute({})

    expect(badge(invited_user.user)).to be_blank
  end

  it "awards the badge to a active user for 6 months with more than 12 days visited" do
    invited_user = Fabricate(:invited_user, created_at: 200.days.ago)
    invited_user.user.update!(
      created_at: 200.days.ago
    )

    invited_user.user.user_stat.update!(
      days_visited: 13
    )

    granter.execute({})

    freeze_time(Time.zone.now + 11.minutes)

    expect(badge(invited_user.user).count).not_to be_blank

    expect(invited_user.user.user_points.sum(:reward_points)).to be(SiteSetting.discourse_rewards_points_for_silver_badges)
  end
end
