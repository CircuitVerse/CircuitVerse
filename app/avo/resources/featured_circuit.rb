# frozen_string_literal: true

class Avo::Resources::FeaturedCircuit < Avo::BaseResource
  self.model_class = ::FeaturedCircuit
  self.title = :id
  self.includes = %i[project]

  def fields
    field :id, as: :id, link_to_record: true

    field :project, as: :belongs_to,
                    required: true,
                    sortable: true,
                    help: "⚠️ Project must be Public to be featured"

    field :created_at, as: :date_time,
                       hide_on: %i[edit new],
                       sortable: true

    field :updated_at, as: :date_time,
                       hide_on: %i[edit new]
  end

  def filters
    filter Avo::Filters::FeaturedCircuitByProject
  end
end
