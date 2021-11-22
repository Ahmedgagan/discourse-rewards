# frozen_string_literal: true

class DiscourseRewards::NonAnonymousUserConstraints
  def matches?(request)
    current_user = CurrentUser.lookup_from_env(request.env)
    !current_user&.anonymous?
  rescue Discourse::InvalidAccess, Discourse::ReadOnly
    false
  end
end
