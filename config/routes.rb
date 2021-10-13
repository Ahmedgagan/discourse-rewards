# frozen_string_literal: true

DiscourseRewards::Engine.routes.draw do
  get "admin/rewards" => "rewards#display"
  get "rewards-leaderboard" => "rewards#leaderboard"
  get "transactions" => "rewards#transactions"
  get "admin/rewards/:reward_id" => "rewards#display"
  post "rewards/:id/grant" => "rewards#grant"
  get "user-rewards" => "rewards#user_rewards"
  post "user-rewards/:id" => "rewards#grant_user_reward"
  delete "user-rewards/:id" => "rewards#cancel_user_reward"
  resources :rewards

  get "points-center" => "rewards#display"
  get "points-center/leaderboard" => "rewards#display"
  get "points-center/available-rewards" => "rewards#display"
end
