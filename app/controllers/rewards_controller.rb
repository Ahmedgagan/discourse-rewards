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

    def cancel_user_reward
      params.require(:id)

      user_reward = DiscourseRewards::UserReward.find(params[:id])
      reward = user_reward.reward

      user_reward.destroy!

      reward.update!(quantity: reward.quantity + 1)

      user_reward_message = {
        user_reward_id: user_reward.id,
        user_reward: user_reward.attributes
      }

      reward_message = {
        reward_id: reward.id,
        reward: reward.attributes,
        quantity: true
      }

      user_message = {
        available_points: user_reward.user.available_points
      }

      MessageBus.publish("/u/rewards", reward_message)
      MessageBus.publish("/u/user-rewards", user_reward_message)
      MessageBus.publish("/u/#{user_reward.user.id}/rewards", user_message)

      render_serialized(user_reward, UserRewardSerializer)
    end

    def leaderboard
      page = params[:page].to_i || 1

      users = User.joins("LEFT OUTER JOIN discourse_rewards_user_points p ON users.id = p.user_id")
        .where("users.id NOT IN(select user_id from anonymous_users) AND silenced_till IS NULL AND active=true AND users.id > 0")
        .group("users.id")
        .select("users.*, COALESCE(SUM(p.reward_points), 0) total_earned_points")
        .order("total_earned_points DESC, users.username_lower")

      count = users.length

      users = users.offset(page * PAGE_SIZE).limit(PAGE_SIZE)

      render_json_dump({ count: count, users: serialize_data(users, BasicUserSerializer) })
    end

    def transactions
      transactions = ActiveRecord::Base.connection.execute("SELECT user_id, null user_reward_id, id point_id, reward_points, created_at FROM discourse_rewards_user_points WHERE user_id=#{current_user.id} UNION SELECT user_id, id, null, points, created_at FROM discourse_rewards_user_rewards WHERE user_id=#{current_user.id} ORDER BY created_at DESC").to_a

      transactions = transactions.map { |transaction| DiscourseRewards::Transaction.new(transaction.with_indifferent_access) }

      render_json_dump({ count: transactions.length, transactions: serialize_data(transactions, TransactionSerializer) })
    end

    def display
    end
  end
end
