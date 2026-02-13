# frozen_string_literal: true

class Avo::Resources::ProjectDatum < Avo::BaseResource
  self.title = :id
  self.includes = %i[project]
  self.model_class = ::ProjectDatum

  def fields
    field :id, as: :id, link_to_resource: true
    field :project, as: :belongs_to, required: true, searchable: true
    field :data, as: :textarea, readonly: true

    field :created_at, as: :date_time, readonly: true, sortable: true
    field :updated_at, as: :date_time, readonly: true
  end
end
