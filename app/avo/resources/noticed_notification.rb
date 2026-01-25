# frozen_string_literal: true

class Avo::Resources::NoticedNotification < Avo::BaseResource
  self.title = :type
  self.includes = [:recipient]
  self.model_class = ::NoticedNotification

  def fields
    field :id, as: :id, link_to_resource: true
    field :type, as: :textarea
    field :recipient, as: :belongs_to, polymorphic_as: :recipient, types: [::User], searchable: true
    field :params, as: :textarea
    field :read_at, as: :date_time, sortable: true

    field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
    field :updated_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
  end

  def filters
    filter Avo::Filters::NoticedNotificationRead
    filter Avo::Filters::NoticedNotificationId
    filter Avo::Filters::NoticedNotificationType
    filter Avo::Filters::NoticedNotificationCreatedAt
    filter Avo::Filters::NoticedNotificationUpdatedAt
  end

  def actions
    action Avo::Actions::ExportNoticedNotifications
  end
end
