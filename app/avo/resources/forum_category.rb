# frozen_string_literal: true

class Avo::Resources::ForumCategory < Avo::BaseResource
  self.title = :name
  self.includes = %i[]
  self.model_class = ::ForumCategory

  def fields
    field :id, as: :id, link_to_resource: true
    field :name, as: :text, sortable: true
    field :slug, as: :text, readonly: true
    field :color, as: :text

    field :created_at, as: :date_time, readonly: true, sortable: true
    field :updated_at, as: :date_time, readonly: true, sortable: true

    field :forum_threads, as: :has_many
  end
end
