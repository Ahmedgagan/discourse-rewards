# frozen_string_literal: true
desc "Grant reward points to user for creating topic, posts & receiving likes"
task "rewards:points" => [:environment] do |_, args|
  require 'highline/import'
  destroy = ask("You are about to Grant reward points to user for creating topic, posts & receiving likes, are you sure ? y/n  ")

  if destroy.downcase != "y"
    raise "You are not sure about the task, aborting the task"
  end

  DiscourseRewards::UserPoint.where(user_badge_id: nil).destroy_all

  posts = Post.where(created_at: Time.zone.now.beginning_of_year..Time.zone.now.end_of_day).where("user_id > 0")

  posts.each do |post|
    description = nil
    points = nil

    if post.post_number == 1
      description = {
        topic_id: post.topic.id,
        topic_title: post.topic.title
      }

      points = SiteSetting.discourse_rewards_points_for_topic_create.to_i
    else
      description = {
        post_id: post.id,
        post_number: post.post_number,
        topic_title: post.topic.title
      }

      points = SiteSetting.discourse_rewards_points_for_post_create.to_i
    end

    DiscourseRewards::UserPoint.create(user_id: post.user_id, reward_points: points, description: description.to_json) if points > 0
  end

  likes = PostAction.where(post_action_type_id: PostActionType.types[:like], post_id: posts.pluck(:id))

  likes.each do |like|
    description = {
      type: 'like',
      post_id: like.post.id,
      topic_title: like.post.topic.title
    }

    points = SiteSetting.discourse_rewards_points_for_like_received.to_i

    DiscourseRewards::UserPoint.create(user_id: like.post.user_id, reward_points: points, description: description.to_json) if points > 0
  end
end
