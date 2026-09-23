# frozen_string_literal: true

class Avo::Resources::Subscription < Avo::BaseResource
  self.title = :id
  self.includes = %i[subscriber comment_thread]
  self.model_class = ::CommentSubscription
  self.devise_password_optional = true

  def fields
    field :id, as: :id, link_to_resource: true
    field :subscriber, as: :belongs_to, polymorphic_as: :subscriber, types: [::User],
                       searchable: true
    field :comment_thread, as: :belongs_to, searchable: true

    field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[edit new]
    field :updated_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[edit new]
  end
end
