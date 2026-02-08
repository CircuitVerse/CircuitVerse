# frozen_string_literal: true

class Avo::Resources::CommontatorComment < Avo::BaseResource
  self.title = :id
  self.includes = %i[creator thread parent children]
  self.model_class = ::Commontator::Comment
  self.devise_password_optional = true

  def fields
    field :id, as: :id, link_to_resource: true
    field :creator, as: :belongs_to, polymorphic_as: :creator, types: [::User], searchable: true
    field :editor, as: :belongs_to, polymorphic_as: :editor, types: [::User]
    field :thread, as: :belongs_to, searchable: true, label: "Discussion"
    field :parent, as: :belongs_to

    field :body, as: :textarea, required: true
    field :deleted_at, as: :date_time, readonly: true
    field :cached_votes_up, as: :number, readonly: true
    field :cached_votes_down, as: :number, readonly: true

    field :children_count, as: :number, readonly: true do
      record.children.count
    end

    field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
    field :updated_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]

    field :children, as: :has_many, readonly: true
  end

  def filters
    filter Avo::Filters::CommentDeleted
    filter Avo::Filters::CommentCreatedAt
    filter Avo::Filters::CommentUpdatedAt
  end

  def actions
    action Avo::Actions::ExportComments
  end
end
