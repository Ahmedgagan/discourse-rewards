# frozen_string_literal: true

module DiscourseRewards
  class RewardsController < ::ApplicationController
    def create
      params.require(:limit, :quantity, :title)

      raise Discourse::InvalidParameters.new(:points) if params[:limit] < 0
      raise Discourse::InvalidParameters.new(:quantity) if params[:quantity] < 0
      raise Discourse::InvalidParameters.new(:title) if !params.has_key?(:title)

      reward = Reward.create(
        uploaded_by: current_user.id,
        points: params[:points],
        quantity: params[:quantity],
        title: params[:title],
        description: params[:description],
        image: params[:image]
      )
    end

    def index
      render json: { rewards: Reward.all }
    end

    def show
      params.require(:id)

      reward = Reward.find(params[:id])

      render json: { reward: reward }
    end

    def update
      params.require(:id)

      reward = Reward.find(params[:id])

      reward.update!(params.permit(:points, :quantity, :title, :description))

      render json: { reward: reward }
    end

    def destroy
      params.require(:id)

      reward = Reward.find(params[:id]).destroy

      render json: reward
    end
  end
end
