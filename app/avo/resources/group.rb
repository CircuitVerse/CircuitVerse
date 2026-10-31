# frozen_string_literal: true

class Avo::Resources::Group < Avo::BaseResource
  self.model_class = ::Group
  self.title = :name
  self.includes = %i[primary_mentor lti_resource_link group_members users assignments pending_invitations]
  # rubocop:disable Metrics/MethodLength
  def fields
    field :id, as: :id, link_to_record: true

    field :name, as: :text,
                 required: true,
                 sortable: true

    field :primary_mentor, as: :belongs_to,
                           required: true,
                           sortable: true,
                           help: "The mentor who created this group"

    # No launch flow writes this yet (the LTI 1.3 launch PR isn't merged), so
    # this is the only way to link an existing LMS group until it lands.
    field :lti_resource_link, as: :belongs_to,
                              help: "The LMS course this group's roster syncs from"

    field :group_token, as: :text,
                        readonly: true,
                        hide_on: %i[new edit], # Hide token fields on forms
                        help: "Secure token for group invitations"

    field :token_expires_at, as: :date_time,
                             hide_on: %i[new edit] # Hide token fields on forms

    field :created_at, as: :date_time,
                       hide_on: %i[edit new],
                       sortable: true

    field :updated_at, as: :date_time,
                       hide_on: %i[edit new]

    # Associations - ALL HIDDEN on new/edit forms!
    field :group_members, as: :has_many,
                          hide_on: %i[new edit]

    field :users, as: :has_many,
                  hide_on: %i[new edit]

    field :assignments, as: :has_many,
                        hide_on: %i[new edit] # CRITICAL: This must be hidden!

    field :pending_invitations, as: :has_many,
                                hide_on: %i[new edit]
  end
  # rubocop:enable Metrics/MethodLength
end
