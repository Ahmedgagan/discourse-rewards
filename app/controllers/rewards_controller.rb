# frozen_string_literal: true

module DiscourseRewards
  class RewardsController < ::ApplicationController
    def create
      params.require([:quantity, :title])

      # raise Discourse::InvalidParameters.new(:points) if params[:limit] < 0
      raise Discourse::InvalidParameters.new(:quantity) if params[:quantity].to_i < 0
      raise Discourse::InvalidParameters.new(:title) unless params.has_key?(:title)

      reward = DiscourseRewards::Reward.create(
        uploaded_by: current_user.id,
        points: params[:points].to_i,
        quantity: params[:quantity].to_i,
        title: params[:title],
        description: params[:description],
        image: params[:image],
        image_url: params[:image_url]
      )

      render json: { reward: reward }
    end

    def index
      render json: { rewards: DiscourseRewards::Reward.order(created_at: :desc) }
    end

    def show
      params.require(:id)

      reward = DiscourseRewards::Reward.find(params[:id])

      render json: { reward: reward }
    end

    def update
      params.require(:id)

      reward = DiscourseRewards::Reward.find(params[:id])

      reward.update!(params.permit(:points, :quantity, :title, :description, :image, :image_url))

      render json: { reward: reward }
    end

    def destroy
      params.require(:id)

      reward = DiscourseRewards::Reward.find(params[:id]).destroy

      render json: { reward: reward }
    end

    def display
    end
  end
end
