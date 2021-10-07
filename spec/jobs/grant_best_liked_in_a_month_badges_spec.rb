# frozen_string_literal: true

require 'rails_helper'

describe Jobs::GrantBestLikedInAMonthBadges do
  let(:granter) { described_class.new }

  it "awards the best liked in a month badge" do
    user = Fabricate(:user, created_at: 400.days.ago)
    user1 = Fabricate(:user, created_at: 400.days.ago)
    user2 = Fabricate(:user, created_at: 400.days.ago)

    post = Fabricate(:post, user: user)
    post1 = Fabricate(:post, user: user1)
    post2 = Fabricate(:post, user: user2)

    PostActionCreator.like(user1, post).post_action
    PostActionCreator.like(user2, post).post_action

    PostActionCreator.like(user1, post2).post_action

    freeze_time = 1.month.from_now.beginning_of_month - Time.zone.now

    freeze_time(Time.zone.now + freeze_time)

    granter.execute({})

    freeze_time(Time.zone.now + 11.minutes)

    badge = user.user_badges.where(badge_id: Badge.find_by(name: 'Best liked in a month').id)
    expect(badge.count).to eq(1)

    expect(user.user_points.sum(:reward_points)).to be(SiteSetting.discourse_rewards_points_for_bronze_badges)
  end
end
