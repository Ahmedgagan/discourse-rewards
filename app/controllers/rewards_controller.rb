# frozen_string_literal: true

module DiscourseRewards
  class RewardsController < ::ApplicationController
    PAGE_SIZE = 30

    def create
      params.require([:quantity, :title])

      raise Discourse::InvalidParameters.new(:quantity) if params[:quantity].to_i < 0
      raise Discourse::InvalidParameters.new(:title) unless params.has_key?(:title)

      reward = DiscourseRewards::Reward.create(
        created_by_id: current_user.id,
        points: params[:points].to_i,
        quantity: params[:quantity].to_i,
        title: params[:title],
        description: params[:description],
        image: params[:image],
        image_url: params[:image_url]
      )

      message = {
        reward_id: reward.id,
        reward: reward.attributes,
        create: true
      }

      MessageBus.publish("/u/rewards", message)

      render_serialized(reward, RewardSerializer)
    end

    def index
      page = params[:page].to_i || 1

      rewards = DiscourseRewards::Reward.order(created_at: :desc).offset(page * PAGE_SIZE).limit(PAGE_SIZE)

      render_serialized(rewards, RewardSerializer)
    end

    def show
      params.require(:id)

      reward = DiscourseRewards::Reward.find(params[:id])

      render_serialized(reward, RewardSerializer)
    end

    def update
      params.require(:id)

      reward = DiscourseRewards::Reward.find(params[:id])

      reward.update!(params.permit(:points, :quantity, :title, :description, :image, :image_url))

      message = {
        reward_id: reward.id,
        reward: reward.attributes
      }

      MessageBus.publish("/u/rewards", message)

      render_serialized(reward, RewardSerializer)
    end

    def destroy
      params.require(:id)

      reward = DiscourseRewards::Reward.find(params[:id]).destroy

      message = {
        reward_id: reward.id,
        reward: reward.attributes,
        destroy: true
      }

      MessageBus.publish("/u/rewards", message)

      render_serialized(reward, RewardSerializer)
    end

    def grant
      params.require(:id)

      reward = DiscourseRewards::Reward.find(params[:id])

      raise Discourse::InvalidAccess if current_user.user_points.sum(:reward_points) < reward.points
      raise Discourse::InvalidAccess if reward.quantity <= 0

      user_reward = DiscourseRewards::UserReward.create(
        user_id: current_user.id,
        reward_id: reward.id,
        status: 'applied',
        points: reward.points
      )

      reward.update!(quantity: user_reward.reward.quantity - 1)

      message = {
        reward_id: reward.id,
        reward: reward.attributes
      }

      MessageBus.publish("/u/rewards", message)

      render_serialized(reward, RewardSerializer)
    end

    def user_rewards
      page = params[:page].to_i || 1

      user_rewards = DiscourseRewards::UserReward.where(status: 'applied').offset(page * PAGE_SIZE).limit(PAGE_SIZE)

      render_serialized(user_rewards, UserRewardSerializer)
    end

    def grant_user_reward
      params.require(:id)

      user_reward = DiscourseRewards::UserReward.find(params[:id])

      raise Discourse::InvalidParameters.new(:id) if !user_reward

      user_reward.update!(status: 'granted')

      message = {
        user_reward_id: user_reward.id,
        user_reward: user_reward.attributes
      }

      MessageBus.publish("/u/user-rewards", message)

      render_serialized(user_reward, UserRewardSerializer)
    end

    def display
    end
  end
end
