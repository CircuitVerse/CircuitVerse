# frozen_string_literal: true

class Avo::Resources::MailkickOptOut < Avo::BaseResource
  self.title = :email
  self.includes = [:user]
  self.model_class = ::Mailkick::OptOut

  def fields
    field :id, as: :id, link_to_resource: true
    field :email, as: :text, sortable: true, required: true

    # Polymorphic user association - shows as dropdown
    field :user, as: :belongs_to, polymorphic_as: :user, types: [::User], sortable: true

    field :active, as: :boolean, sortable: true
    field :reason, as: :text
    field :list, as: :text, sortable: true

    field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
    field :updated_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
  end

  def filters
    filter Avo::Filters::MailkickActive
    filter Avo::Filters::MailkickList
    filter Avo::Filters::MailkickEmail
    filter Avo::Filters::MailkickUserType
  end

  def actions
    action Avo::Actions::ExportMailkickOptOuts
  end
end
