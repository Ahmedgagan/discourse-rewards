# frozen_string_literal: true

require 'rails_helper'

describe Jobs::GrantActiveMemberBadges do
  let(:granter) { described_class.new }

  it "doesn't award to a user who not an invited_user" do
    user = Fabricate(:user, created_at: 1.month.ago)

    granter.execute({})

    badge = user.user_badges.where(badge_id: Badge.find_by(name: 'Active Member').id)
    expect(badge).to be_blank
  end

  it "doesn't award to a user who is less than a year old" do
    invited_user = Fabricate(:invited_user, created_at: 1.month.ago)

    granter.execute({})

    badge = invited_user.user.user_badges.where(badge_id: Badge.find_by(name: 'Active Member').id)
    expect(badge).to be_blank
  end

  it "doesn't award to a user who not an invited_user" do
    invited_user = Fabricate(:invited_user, created_at: 1.month.ago)

    granter.execute({})

    badge = invited_user.user.user_badges.where(badge_id: Badge.find_by(name: 'Active Member').id)
    expect(badge).to be_blank
  end

  it "doesn't award to a invited_user with less than 24 visited days" do
    invited_user = Fabricate(:invited_user, created_at: 400.days.ago)

    invited_user.user.update!(
      created_at: 400.days.ago
    )

    granter.execute({})

    badge = invited_user.user.user_badges.where(badge_id: Badge.find_by(name: 'Active Member').id)
    expect(badge).to be_blank
  end

  it "awards the badge to a active user for a year with minimum 24 days visited" do
    invited_user = Fabricate(:invited_user, created_at: 400.days.ago)
    invited_user.user.update!(
      created_at: 400.days.ago
    )

    invited_user.user.user_stat.update!(
      days_visited: 30
    )

    granter.execute({})

    freeze_time(Time.zone.now + 11.minutes)

    badge = invited_user.user.user_badges.where(badge_id: Badge.find_by(name: 'Active Member').id)
    expect(badge.count).to eq(1)

    expect(invited_user.user.user_points.sum(:reward_points)).to be(200)
  end
end
