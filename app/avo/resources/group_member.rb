# frozen_string_literal: true

class Avo::Resources::GroupMember < Avo::BaseResource
  self.model_class = ::GroupMember
  self.title = :id
  self.includes = %i[group user assignments]
  # rubocop:disable Metrics/MethodLength
  def fields
    field :id, as: :id, link_to_record: true

    field :group, as: :belongs_to,
                  required: true,
                  sortable: true

    field :user, as: :belongs_to,
                 required: true,
                 sortable: true,
                 help: "The user who is a member of this group"

    field :mentor, as: :boolean,
                   help: "Is this member a mentor or a student?"

    field :created_at, as: :date_time,
                       hide_on: %i[edit new],
                       sortable: true

    field :updated_at, as: :date_time,
                       hide_on: %i[edit new]

    # Show related assignments through the group
    field :assignments, as: :has_many,
                        hide_on: %i[new edit]
  end
  # rubocop:enable Metrics/MethodLength

  def filters
    filter Avo::Filters::GroupMemberByGroup
    filter Avo::Filters::GroupMemberMentorOnly
  end
end
