# frozen_string_literal: true

module Jobs
  class GrantConversationMakerBadges < ::Jobs::Scheduled
    every 1.day

    def execute(args)
      return if Date.today != Date.today.at_beginning_of_month

      badge = Badge.find_by_name('Conversation Maker')
      return unless SiteSetting.enable_badges? && badge.enabled?

      previous_month_beginning = 1.month.ago.beginning_of_month
      previous_month_end = 1.month.ago.end_of_month

      user_id = DB.query_single <<~SQL
        SELECT t.user_id
        FROM topics t INNER JOIN posts p ON t.id = p.topic_id
        WHERE t.deleted_at IS NULL AND p.deleted_at IS NULL AND t.user_id > 0 AND p.created_at BETWEEN '#{previous_month_beginning}' AND '#{previous_month_end}'
        GROUP BY t.id
        ORDER BY count(p.id) DESC
        LIMIT 1
      SQL

      User.where(id: user_id).find_each do |user|
        BadgeGranter.grant(badge, user)
      end
    end
  end
end
