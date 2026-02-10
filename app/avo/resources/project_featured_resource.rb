# frozen_string_literal: true

class ProjectFeaturedResource < Avo::BaseResource
  self.title = :id
  self.search = [:id]
  self.includes = [:project]

  # Fields
  field :id, as: :id
  field :project, as: :belongs_to, searchable: true
  field :featured_at, as: :date_time
  
  # Timestamps
  field :created_at, as: :date_time, readonly: true
  field :updated_at, as: :date_time, readonly: true
  
  # Filters
  filter :project, as: :select, options: -> { Project.all.map { |p| [p.name, p.id] } }
  filter :featured_at, as: :date_range
  filter :created_at, as: :date_range
  
  # Index configuration
  index do
    select :id
    select :project
    select :featured_at
    select :created_at
  end
  
  # Show configuration
  show do
    field :id
    field :project
    field :featured_at
    field :created_at
    field :updated_at
  end
  
  # Form configuration
  form do
    field :project
    field :featured_at
  end
end
