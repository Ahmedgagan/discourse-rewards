# frozen_string_literal: true

DiscourseRewards::Engine.routes.draw do
  get "admin/rewards" => "rewards#display"
  get "admin/rewards/:reward_id" => "rewards#display"
  resources :rewards, constraints: StaffConstraint.new
end
