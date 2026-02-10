# frozen_string_literal: true

class CollaborationResource < Avo::BaseResource
  self.title = :id
  self.search = [:id]
  self.includes = [:user, :project]

  # Fields
  field :id, as: :id
  field :user, as: :belongs_to, searchable: true
  field :project, as: :belongs_to, searchable: true
  
  # Timestamps
  field :created_at, as: :date_time, readonly: true
  field :updated_at, as: :date_time, readonly: true
  
  # Filters
  filter :user, as: :select, options: -> { User.all.map { |u| [u.name, u.id] } }
  filter :project, as: :select, options: -> { Project.all.map { |p| [p.name, p.id] } }
  filter :created_at, as: :date_range
  
  # Index configuration
  index do
    select :id
    select :user
    select :project
    select :created_at
  end
  
  # Show configuration
  show do
    field :id
    field :user
    field :project
    field :created_at
    field :updated_at
  end
  
  # Form configuration
  form do
    field :user
    field :project
  end
end
