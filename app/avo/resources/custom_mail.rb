# frozen_string_literal: true

class Avo::Resources::CustomMail < Avo::BaseResource
  self.title = :subject
  self.includes = %i[sender]
  self.model_class = ::CustomMail

  def fields
    field :id, as: :id, link_to_resource: true
    field :sender, as: :belongs_to, searchable: true
    field :subject, as: :text, required: true
    field :body, as: :textarea, required: true
    field :content, as: :textarea
    field :sent, as: :boolean, show_on: %i[index show new edit]
    field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
    field :updated_at, as: :date_time, readonly: true, hide_on: %i[new edit]
  end
end
