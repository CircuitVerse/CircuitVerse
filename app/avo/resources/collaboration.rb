# frozen_string_literal: true

class Avo::Resources::Collaboration < Avo::BaseResource
  self.model_class = ::Collaboration
  self.title = :id
  self.includes = %i[user project]

  def fields
    field :id, as: :id, link_to_record: true

    field :user, as: :belongs_to,
                 required: true,
                 sortable: true,
                 help: "Collaborating user"

    field :project, as: :belongs_to,
                    required: true,
                    sortable: true,
                    help: "Project being collaborated on"

    field :created_at, as: :date_time,
                       hide_on: %i[new edit],
                       sortable: true

    field :updated_at, as: :date_time,
                       hide_on: %i[new edit]
  end
end
