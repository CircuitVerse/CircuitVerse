# frozen_string_literal: true

class Avo::Resources::PushSubscription < Avo::BaseResource
  self.title = :id
  self.includes = %i[user]
  self.model_class = ::PushSubscription

  def fields
    field :id, as: :id, link_to_resource: true
    field :user, as: :belongs_to, required: true, searchable: true
    field :endpoint, as: :text
    field :p256dh, as: :text
    field :auth, as: :text

    field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
    field :updated_at, as: :date_time, readonly: true, hide_on: %i[new edit]
  end
end
