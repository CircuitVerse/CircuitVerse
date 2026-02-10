# frozen_string_literal: true

class ProjectDatumResource < Avo::BaseResource
  self.title = :id
  self.search = [:id]
  self.includes = [:project]

  # Fields
  field :id, as: :id
  field :project, as: :belongs_to, searchable: true
  field :data, as: :code, format_using: -> { value value&.truncate(100) }
  
  # Timestamps
  field :created_at, as: :date_time, readonly: true
  field :updated_at, as: :date_time, readonly: true
  
  # Filters
  filter :project, as: :select, options: -> { Project.all.map { |p| [p.name, p.id] } }
  filter :created_at, as: :date_range
  
  # Index configuration
  index do
    select :id
    select :project
    select :data, format_using: -> { value value&.truncate(50) }
    select :created_at
  end
  
  # Show configuration
  show do
    field :id
    field :project
    field :data
    field :created_at
    field :updated_at
  end
  
  # Form configuration
  form do
    field :project
    field :data
  end
end
