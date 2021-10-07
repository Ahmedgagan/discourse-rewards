# frozen_string_literal: true

WikiMaster = <<~SQL
  SELECT p.user_id, p.id, p.created_at granted_at
  FROM
  (
    SELECT min(p.id) id
    FROM badge_posts p
    JOIN topics t on t.id = p.topic_id
		    WHERE p.wiki = true
        AND p.post_number = 1
        AND (:backfill OR p.id IN (:post_ids))
    GROUP BY t.user_id
  ) as X
  JOIN posts p ON p.id = X.id
SQL

BadgeGrouping.seed do |g|
  g.id = 6
  g.name = 'Reward Badges'
  g.default_position = 0
end

Badge.seed(:name) do |b|
  b.name = "Best liked in a month"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = true
  b.target_posts = false
  b.show_posts = false
  b.query = nil
  b.default_badge_grouping_id = 6
  b.trigger = Badge::Trigger::None
  b.system = true
end

Badge.seed(:name) do |b|
  b.name = "Conversation Maker"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = true
  b.target_posts = false
  b.show_posts = false
  b.query = nil
  b.default_badge_grouping_id = 6
  b.trigger = Badge::Trigger::None
  b.system = true
end

Badge.seed(:name) do |b|
  b.name = "Embassador"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.target_posts = false
  b.show_posts = false
  b.query = nil
  b.default_badge_grouping_id = 6
  b.trigger = Badge::Trigger::None
  b.system = true
end

Badge.seed(:name) do |b|
  b.name = "Wiki Master"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = true
  b.target_posts = false
  b.show_posts = false
  b.query = WikiMaster
  b.default_badge_grouping_id = 6
  b.trigger = Badge::Trigger::PostRevision
  b.system = true
end

Badge.seed(:name) do |b|
  b.name = "Interested"
  b.badge_type_id = BadgeType::Bronze
  b.multiple_grant = false
  b.target_posts = false
  b.show_posts = false
  b.query = nil
  b.default_badge_grouping_id = 6
  b.trigger = Badge::Trigger::PostRevision
  b.system = true
end

Badge.seed(:name) do |b|
  b.name = "Obsessed"
  b.badge_type_id = BadgeType::Silver
  b.multiple_grant = false
  b.target_posts = false
  b.show_posts = false
  b.query = nil
  b.default_badge_grouping_id = 6
  b.trigger = Badge::Trigger::PostRevision
  b.system = true
end

Badge.seed(:name) do |b|
  b.name = "Active Member"
  b.badge_type_id = BadgeType::Gold
  b.multiple_grant = false
  b.target_posts = false
  b.show_posts = false
  b.query = nil
  b.default_badge_grouping_id = 6
  b.trigger = Badge::Trigger::PostRevision
  b.system = true
end
