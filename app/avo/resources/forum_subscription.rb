# frozen_string_literal: true

class Avo::Resources::ForumSubscription < Avo::BaseResource
  self.title = :id
  self.includes = %i[forum_thread user]
  self.model_class = ::ForumSubscription

  def fields
    field :id, as: :id, link_to_resource: true
    field :forum_thread, as: :belongs_to, searchable: true
    field :user, as: :belongs_to, searchable: true
    field :subscription_type, as: :select, options: lambda {
      {
        "optin" => "Opt-in",
        "optout" => "Opt-out"
      }
    }
    field :created_at, as: :date_time, readonly: true, sortable: true
  end

  def filters
    filter Avo::Filters::ForumSubscriptionType
  end
end
