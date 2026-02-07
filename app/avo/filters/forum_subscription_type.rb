# frozen_string_literal: true

class Avo::Filters::ForumSubscriptionType < Avo::Filters::SelectFilter
  self.name = "Subscription Type"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(subscription_type: value)
  end

  def options
    { optin: "Opt-in", optout: "Opt-out" }
  end
end
