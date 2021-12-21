# frozen_string_literal: true
desc "Grant reward points to user for creating topic, posts & receiving likes"
task "rewards:points" => [:environment] do |_, args|
  require 'highline/import'
  destroy = ask("You are about to Grant reward points to user for creating topic, posts & receiving likes, are you sure ? y/n  ")

  if destroy.downcase != "y"
    raise "You are not sure about the task, aborting the task"
  end

  DiscourseRewards::UserPoint.where(user_badge_id: nil, user_points_category_id: [2, 4]).destroy_all

  posts = Post.where(created_at: Time.zone.now.beginning_of_year..Time.zone.now.end_of_day).where("user_id > 0")

  posts.each do |post|
    next if !post.topic

    description = nil
    points = nil

    if post.post_number == 1
      description = {
        type: 'topic',
        post_number: 1,
        topic_slug: post.topic.slug,
        topic_id: post.topic.id,
        topic_title: post.topic.title
      }

      points = SiteSetting.discourse_rewards_points_for_topic_create.to_i
    else
      description = {
        type: 'post',
        post_id: post.id,
        post_number: post.post_number,
        topic_slug: post.topic.slug,
        topic_id: post.topic.id,
        topic_title: post.topic.title
      }

      points = SiteSetting.discourse_rewards_points_for_post_create.to_i
    end

    DiscourseRewards::UserPoint.create(user_id: post.user_id, reward_points: points, user_points_category_id: 2, description: description.to_json) if points > 0
  end

  likes = PostAction.where(post_action_type_id: PostActionType.types[:like], post_id: posts.pluck(:id))

  likes.each do |like|
    description = {
      type: 'like',
      post_id: like.post.id,
      post_number: like.post.post_number,
      topic_id: like.post.topic.id,
      topic_slug: like.post.topic.slug,
      topic_title: like.post.topic.title
    }

    points = SiteSetting.discourse_rewards_points_for_like_received.to_i

    DiscourseRewards::UserPoint.create(user_id: like.post.user_id, reward_points: points, user_points_category_id: 4, description: description.to_json) if points > 0
  end
end

desc "Add Category to all points granted till date"
task "rewards:add_points_category" => [:environment] do |_, args|
  require 'highline/import'
  update = ask("You are about to add category to all the transactions/points ? y/n  ")

  if update.downcase != "y"
    raise "You are not sure about the task, aborting the task"
  end

  DiscourseRewards::UserPoint.where.not(user_badge_id: nil).update_all(user_points_category_id: 1)
  DiscourseRewards::UserPoint.where(user_badge_id: nil).each do |user_point|
    description = JSON.parse(user_point.description).with_indifferent_access
    if description[:type] == "topic" || description[:type] == "post"
      user_point.update(user_points_category_id: 2)
    end

    if description[:type] == "daily_login"
      user_point.update(user_points_category_id: 3)
    end

    if description[:type] == "like"
      user_point.update(user_points_category_id: 4)
    end
  end
end
