# frozen_string_literal: true

class Avo::Resources::NoticedNotification < Avo::BaseResource
  self.title = :type
  self.includes = [:recipient]
  self.model_class = ::NoticedNotification

  def fields
    field :id, as: :id, link_to_resource: true
    field :recipient, as: :belongs_to, polymorphic_as: :recipient, types: [::User], searchable: true
    field :type, as: :text
    field :params, as: :textarea
    field :read_at, as: :date_time, sortable: true

    field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
    field :updated_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
  end
end
