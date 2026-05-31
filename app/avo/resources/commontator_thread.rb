# frozen_string_literal: true

class Avo::Resources::CommontatorThread < Avo::BaseResource
  self.title = :id
  self.includes = %i[commontable comments subscriptions]
  self.model_class = ::Commontator::Thread
  self.devise_password_optional = true
  self.record_selector = true

  def fields
    field :id, as: :id, link_to_resource: true
    field :commontable, as: :belongs_to, polymorphic_as: :commontable, types: [::Project], searchable: true
    field :closed_at, as: :date_time, sortable: true

    field :comments_count, as: :number, readonly: true do
      record.comments.count
    end

    field :subscriptions_count, as: :number, readonly: true do
      record.subscriptions.count
    end

    field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
    field :updated_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]

    field :comments, as: :has_many
    field :subscriptions, as: :has_many
  end
end
