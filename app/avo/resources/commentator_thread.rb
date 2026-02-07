# frozen_string_literal: true

class Avo::Resources::CommentatorThread < Avo::BaseResource
  self.title = :id
  self.includes = %i[commontable comments subscriptions]
  self.model_class = ::Commontator::Thread
  self.devise_password_optional = true
  self.record_selector = true

  def fields
    field :id, as: :id, link_to_resource: true
    field :commontable, as: :belongs_to, polymorphic_as: :commontable, types: [::Project], searchable: true
    field :closed_at, as: :date_time, sortable: true

    # Counts for associations
    field :comments_count, as: :number, readonly: true do
      record.comments.count
    end

    field :subscriptions_count, as: :number, readonly: true do
      record.subscriptions.count
    end

    field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
    field :updated_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]

    # Associations
    field :comments, as: :has_many
    field :subscriptions, as: :has_many
  end

  def filters
    filter Avo::Filters::ThreadClosed
    filter Avo::Filters::ThreadCreatedAt
    filter Avo::Filters::ThreadUpdatedAt
  end

  def actions
    action Avo::Actions::ExportThreads
  end
end
