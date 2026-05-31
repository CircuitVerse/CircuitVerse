# frozen_string_literal: true

class Avo::Resources::ForumSubscription < Avo::BaseResource
  self.title = :id
  self.includes = %i[forum_thread user]
  self.model_class = ::ForumSubscription

  def fields
    basic_fields
    subscription_fields
    timestamp_fields
  end

  private

    def basic_fields
      field :id, as: :id, link_to_resource: true
      field :forum_thread, as: :belongs_to, searchable: true
      field :user, as: :belongs_to, searchable: true
    end

    def subscription_fields
      field :subscription_type, as: :select, options: lambda {
        {
          "Opt-in" => "optin",
          "Opt-out" => "optout"
        }
      }
    end

    def timestamp_fields
      field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
      field :updated_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
    end
end
