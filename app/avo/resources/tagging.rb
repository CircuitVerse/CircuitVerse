# frozen_string_literal: true

class Avo::Resources::Tagging < Avo::BaseResource
  self.title = :id
  self.includes = %i[tag project]
  self.model_class = ::Tagging

  def fields
    field :id, as: :id, link_to_resource: true
    field :tag, as: :belongs_to, required: true, searchable: true
    field :project, as: :belongs_to, required: true, searchable: true

    field :created_at, as: :date_time, readonly: true, sortable: true
  end
end
