# frozen_string_literal: true

class ProjectResource < Avo::BaseResource
  self.title = :name
  self.search = [:name, :description]
  self.includes = [:author, :collaborators, :stars, :tags]

  # Fields
  field :id, as: :id
  field :name, as: :text, required: true
  field :slug, as: :text, readonly: true
  field :description, as: :textarea, format_using: -> { value value&.truncate(100) }
  field :author, as: :belongs_to, searchable: true
  field :forked_project, as: :belongs_to, optional: true
  field :assignment, as: :belongs_to, optional: true
  field :image_preview, as: :file, is_image: true, direct_upload: true
  field :circuit_preview, as: :file, is_image: true, direct_upload: true
  field :featured_circuit, as: :has_one
  field :grade, as: :has_one
  
  # Relations
  field :stars, as: :has_many
  field :collaborations, as: :has_many
  field :collaborators, as: :has_many, through: :collaborations
  field :taggings, as: :has_many
  field :tags, as: :has_many, through: :taggings
  
  # Timestamps
  field :created_at, as: :date_time, readonly: true
  field :updated_at, as: :date_time, readonly: true
  
  # Filters
  filter :name, as: :text
  filter :author, as: :select, options: -> { User.all.map { |u| [u.name, u.id] } }
  filter :created_at, as: :date_range
  
  # Actions
  action :toggle_featured, name: "Toggle Featured", icon: "heroicons/star"
  action :export_project, name: "Export Project", icon: "heroicons/arrow-down-tray"
  
  # Index configuration
  index do
    select :id
    select :name
    select :author
    select :description, format_using: -> { value value&.truncate(50) }
    select :stars, as: :count
    select :collaborators, as: :count
    select :created_at
  end
  
  # Show configuration
  show do
    field :id
    field :name
    field :slug
    field :description
    field :author
    field :forked_project
    field :assignment
    field :image_preview
    field :circuit_preview
    field :featured_circuit
    field :grade
    field :stars
    field :collaborations
    field :collaborators
    field :taggings
    field :tags
    field :created_at
    field :updated_at
  end
  
  # Form configuration
  form do
    field :name, required: true
    field :description
    field :author
    field :forked_project
    field :assignment
    field :image_preview
    field :circuit_preview
    field :tags
  end
end
