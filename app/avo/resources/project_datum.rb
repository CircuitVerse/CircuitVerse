# frozen_string_literal: true

class Avo::Resources::ProjectDatum < Avo::BaseResource
  self.title = :id
  self.includes = %i[project]
  self.model_class = ::ProjectDatum
  self.index_query = lambda {
    query.select(:id, :project_id, :created_at, :updated_at)
  }

  def fields
    field :id, as: :id, link_to_record: true
    field :project, as: :belongs_to, required: true, searchable: true
    field :data, as: :textarea, readonly: true, hide_on: %i[index]

    field :created_at, as: :date_time, readonly: true, sortable: true
    field :updated_at, as: :date_time, readonly: true
  end
end
