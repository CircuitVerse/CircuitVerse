# frozen_string_literal: true

class Avo::Resources::Thread < Avo::BaseResource
  self.title = :id
  self.includes = %i[commontable closer comments subscriptions]
  self.model_class = ::Commontator::Thread
  self.devise_password_optional = true

  def fields
    field :id, as: :id, link_to_resource: true
    field :commontable, as: :belongs_to, polymorphic_as: :commontable, types: [::Project], searchable: true
    field :closer, as: :belongs_to, polymorphic_as: :closer, types: [::User]
    field :closed_at, as: :date_time

    field :created_at, as: :date_time, readonly: true, sortable: true
    field :updated_at, as: :date_time, readonly: true

    field :comments, as: :has_many
    field :subscriptions, as: :has_many
  end

  def filters
    filter Avo::Filters::ThreadClosed
  end
end
