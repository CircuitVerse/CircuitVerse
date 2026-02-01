# frozen_string_literal: true

class Avo::Resources::Star < Avo::BaseResource
  self.model_class = ::Star
  self.title = :id
  self.includes = %i[user project]

  def fields
    field :id, as: :id, link_to_record: true

    field :user, as: :belongs_to,
                 required: true,
                 sortable: true,
                 help: "User who starred the project"

    field :project, as: :belongs_to,
                    required: true,
                    sortable: true,
                    help: "Project that was starred"

    field :created_at, as: :date_time,
                       hide_on: %i[new edit],
                       sortable: true
  end

  def filters
    filter Avo::Filters::StarByUser
    filter Avo::Filters::StarByProject
  end
end
