# frozen_string_literal: true

class Avo::Resources::MailkickOptOut < Avo::BaseResource
  self.title = :email
  self.includes = []
  self.model_class = ::Mailkick::OptOut

  def fields
    field :id, as: :id, link_to_resource: true
    field :email, as: :text, sortable: true
    field :user_type, as: :text
    field :user_id, as: :number
    field :active, as: :boolean, sortable: true
    field :reason, as: :textarea
    field :list, as: :text

    field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
    field :updated_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
  end

  def filters
    filter Avo::Filters::MailkickActive
    filter Avo::Filters::MailkickList
  end

  def actions
    action Avo::Actions::ExportMailkickOptOuts
  end
end
