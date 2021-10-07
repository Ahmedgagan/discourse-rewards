# frozen_string_literal: true

module Jobs
  class GrantBestLikedInAMonthBadges < ::Jobs::Scheduled
    every 1.day

    def execute(args)
      return if Date.today != Date.today.at_beginning_of_month

      badge = Badge.find_by_name('Best liked in a month')
      return unless SiteSetting.enable_badges? && badge.enabled?

      previous_month_beginning = 1.month.ago.beginning_of_month
      previous_month_end = 1.month.ago.end_of_month

      user_id = DB.query_single <<~SQL
        SELECT p.user_id, count(p.id)
        FROM post_actions pa
        INNER JOIN posts p
        ON pa.post_id = p.id
        INNER JOIN users u
        ON p.user_id = u.id
        WHERE pa.post_action_type_id=2
        AND pa.created_at BETWEEN '#{previous_month_beginning}' AND '#{previous_month_end}'
        GROUP BY p.user_id
        ORDER BY count(p.user_id) DESC
        LIMIT 1
      SQL

      User.where(id: user_id).find_each do |user|
        BadgeGranter.grant(badge, user)
      end
    end
  end
end
