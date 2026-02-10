# frozen_string_literal: true

class ProjectAccessTypeResource < Avo::BaseResource
  self.title = :id
  self.search = [:id]

  # Fields
  field :id, as: :id
  field :name, as: :text, required: true
  field :description, as: :textarea
  
  # Timestamps
  field :created_at, as: :date_time, readonly: true
  field :updated_at, as: :date_time, readonly: true
  
  # Filters
  filter :name, as: :text
  filter :created_at, as: :date_range
  
  # Index configuration
  index do
    select :id
    select :name
    select :description, format_using: -> { value value&.truncate(50) }
    select :created_at
  end
  
  # Show configuration
  show do
    field :id
    field :name
    field :description
    field :created_at
    field :updated_at
  end
  
  # Form configuration
  form do
    field :name, required: true
    field :description
  end
end
