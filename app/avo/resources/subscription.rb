# frozen_string_literal: true

class Avo::Resources::Subscription < Avo::BaseResource
  self.title = :id
  self.includes = %i[subscriber thread]
  self.model_class = ::Commontator::Subscription
  self.devise_password_optional = true

  def fields
    field :id, as: :id, link_to_resource: true
    field :subscriber, as: :belongs_to, polymorphic_as: :subscriber, types: [::User], searchable: true
    field :thread, as: :belongs_to, searchable: true

    field :created_at, as: :date_time, readonly: true, sortable: true
    field :updated_at, as: :date_time, readonly: true
  end
end
