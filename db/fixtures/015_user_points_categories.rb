# frozen_string_literal: true

DiscourseRewards::UserPointsCategory.seed(:name) do |c|
  c.id = 1
  c.name = "reward_badges"
  c.slug = "Reward Badges"
  c.description = "Earned a Reward badge."
end

DiscourseRewards::UserPointsCategory.seed(:name) do |c|
  c.id = 2
  c.name = "creation"
  c.slug = "Topics/Posts created"
  c.description = "Earned points for creating topics/posts."
end

DiscourseRewards::UserPointsCategory.seed(:name) do |c|
  c.id = 3
  c.name = "daily_login"
  c.slug = "Daily Login"
  c.description = "Earned points for daily login to the forum."
end

DiscourseRewards::UserPointsCategory.seed(:name) do |c|
  c.id = 4
  c.name = "like_received"
  c.slug = "Like Received"
  c.description = "Earned points for receiving a like on a post."
end

DiscourseRewards::UserPointsCategory.seed(:name) do |c|
  c.id = 5
  c.name = "rewards_earned"
  c.slug = "Rewards Earned"
  c.description = "Redeemed points for getting reward."
end

DiscourseRewards::UserPointsCategory.seed(:name) do |c|
  c.id = 6
  c.name = "invited_user_joined"
  c.slug = "Invited User Joined"
  c.description = "Earned points for invited user joined the forum."
end
