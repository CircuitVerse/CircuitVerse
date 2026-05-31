# frozen_string_literal: true

class Avo::Resources::MailkickOptOut < Avo::BaseResource
  self.title = :email
  self.model_class = ::Mailkick::OptOut

  def fields
    field :id, as: :id, link_to_resource: true
    field :email, as: :text, sortable: true, required: true

    field :active, as: :boolean, sortable: true
    field :reason, as: :text
    field :list, as: :text, sortable: true

    field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
    field :updated_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
  end
end
