# frozen_string_literal: true

module Jobs
  class GrantEmbassadorBadges < ::Jobs::Scheduled
    every 1.day

    def execute(args)
      badge = Badge.find_by_name('Embassador')
      return unless SiteSetting.enable_badges? && badge.enabled?

      user_ids = DB.query_single <<~SQL
        SELECT u.id FROM users u
        INNER JOIN invited_users iu ON iu.user_id = u.id
        WHERE u.trust_level > 1 AND
          u.active AND
          u.silenced_till IS NULL
      SQL

      User.where(id: user_ids).find_each do |user|
        BadgeGranter.grant(badge, user)
      end
    end
  end
end
