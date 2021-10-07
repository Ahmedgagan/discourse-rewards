# frozen_string_literal: true

module Jobs
  class GrantActiveMemberSilverBadges < ::Jobs::Scheduled
    every 1.day

    def execute(args)
      badge = Badge.find_by_name('Obsessed')
      return unless SiteSetting.enable_badges? && badge.enabled?
      six_months = 6.months.ago.iso8601(6)

      user_ids = DB.query_single <<~SQL
        SELECT u.id FROM users u
        INNER JOIN user_stats us ON u.id = us.user_id
        WHERE us.days_visited > 12 AND
          u.active AND
          u.silenced_till IS NULL AND
          u.created_at < '#{six_months}'
      SQL

      User.where(id: user_ids).find_each do |user|
        BadgeGranter.grant(badge, user)
      end
    end
  end
end
