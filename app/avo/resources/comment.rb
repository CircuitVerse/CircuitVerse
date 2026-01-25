# frozen_string_literal: true

class Avo::Resources::Comment < Avo::BaseResource
  self.title = :id
  self.includes = %i[creator thread parent]
  self.model_class = ::Commontator::Comment
  self.devise_password_optional = true

  def fields
    field :id, as: :id, link_to_resource: true
    field :creator, as: :belongs_to, polymorphic_as: :creator, types: [::User], searchable: true
    field :editor, as: :belongs_to, polymorphic_as: :editor, types: [::User]
    field :thread, as: :belongs_to, searchable: true
    field :parent, as: :belongs_to

    field :body, as: :textarea, required: true
    field :deleted_at, as: :date_time, readonly: true
    field :cached_votes_up, as: :number, readonly: true
    field :cached_votes_down, as: :number, readonly: true

    field :created_at, as: :date_time, readonly: true, sortable: true
    field :updated_at, as: :date_time, readonly: true

    field :children, as: :has_many
  end

  def filters
    filter Avo::Filters::CommentDeleted
  end
end
