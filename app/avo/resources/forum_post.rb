# frozen_string_literal: true

class Avo::Resources::ForumPost < Avo::BaseResource
  self.title = :id
  self.includes = %i[forum_thread user]
  self.model_class = ::ForumPost

  def fields
    field :id, as: :id, link_to_resource: true
    field :forum_thread, as: :belongs_to, searchable: true
    field :user, as: :belongs_to, searchable: true
    field :body, as: :text, code: false

    field :created_at, as: :date_time, readonly: true, sortable: true
    field :updated_at, as: :date_time, readonly: true, sortable: true
  end
end
