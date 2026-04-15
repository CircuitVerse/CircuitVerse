# frozen_string_literal: true

class Avo::Resources::PendingInvitation < Avo::BaseResource
  self.title = :email
  self.includes = %i[group]
  self.model_class = ::PendingInvitation

  def fields
    field :id, as: :id, link_to_resource: true
    field :email, as: :text, required: true
    field :group, as: :belongs_to, required: true, searchable: true

    field :created_at, as: :date_time, readonly: true, sortable: true
    field :updated_at, as: :date_time, readonly: true
  end
end
