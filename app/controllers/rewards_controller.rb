# frozen_string_literal: true

module DiscourseRewards
  class RewardsController < ::ApplicationController
    requires_login
    before_action :ensure_admin, only: [:create, :update, :destroy, :grant_user_reward]

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
        upload_id: params[:upload_id],
        upload_url: params[:upload_url]
      )

      message = {
        reward_id: reward.id,
        reward: reward.attributes,
        create: true
      }

      MessageBus.publish("/u/rewards", message)

      PostUpload.create(post_id: Post.first.id, upload_id: params[:upload_id]) unless PostUpload.find_by(upload_id: params[:upload_id])

      render_serialized(reward, RewardSerializer)
    end

    def index
      page = params[:page].to_i || 1

      rewards = DiscourseRewards::Reward.order(created_at: :desc).offset(page * PAGE_SIZE).limit(PAGE_SIZE)

      reward_list = DiscourseRewards::RewardList.new(rewards: rewards, count: DiscourseRewards::Reward.all.count)

      render_serialized(reward_list, RewardListSerializer)
    end

    def show
      params.require(:id)

      reward = DiscourseRewards::Reward.find(params[:id])

      render_serialized(reward, RewardSerializer)
    end

    def update
      params.require(:id)

      reward = DiscourseRewards::Reward.find(params[:id])

      reward.update!(params.permit(:points, :quantity, :title, :description, :upload_id, :upload_url))

      message = {
        reward_id: reward.id,
        reward: reward.attributes,
        update: true
      }

      MessageBus.publish("/u/rewards", message)

      PostUpload.create(post_id: Post.first.id, upload_id: params[:upload_id]) if params[:upload_id] && !PostUpload.find_by(upload_id: params[:upload_id])

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

      reward.update!(quantity: reward.quantity - 1)

      message = {
        reward_id: reward.id,
        reward: reward.attributes,
        quantity: true
      }

      current_user_message = {
        available_points: current_user.available_points
      }

      MessageBus.publish("/u/rewards", message)
      MessageBus.publish("/u/#{current_user.id}/rewards", current_user_message)

      render_serialized(reward, RewardSerializer)
    end

    def user_rewards
      page = params[:page].to_i || 1

      user_rewards = DiscourseRewards::UserReward.where(status: 'applied').offset(page * PAGE_SIZE).limit(PAGE_SIZE)

      user_reward_list = DiscourseRewards::UserRewardList.new(user_rewards: user_rewards, count: DiscourseRewards::UserReward.where(status: 'applied').count)

      render_serialized(user_reward_list, UserRewardListSerializer)
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

      PostCreator.new(
        current_user,
        title: 'Reward Grant',
        raw: "We are glad to announce that @#{user_reward.user.username} has won #{user_reward.reward.title} Award",
        category: SiteSetting.discourse_rewards_grant_topic_category,
        skip_validations: true
      ).create!

      MessageBus.publish("/u/user-rewards", message)

      render_serialized(user_reward, UserRewardSerializer)
    end

    def leaderboard
      page = params[:page].to_i || 1

      users = User.where("silenced_till IS NULL AND active=true AND id>0")

      count = users.count

      users = users.offset(page * PAGE_SIZE).limit(PAGE_SIZE)

      users = users.sort_by { |user| [-user.total_earned_points.to_i, user[:username_lower]] }

      render_json_dump({ count: count, users: serialize_data(users, BasicUserSerializer) })
    end

    def display
    end
  end
end
