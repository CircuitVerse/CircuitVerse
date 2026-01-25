# frozen_string_literal: true

class Avo::Resources::ForumThread < Avo::BaseResource
  self.title = :title
  self.includes = %i[forum_category user forum_posts]
  self.model_class = ::ForumThread

  def fields
    field :id, as: :id, link_to_resource: true
    field :title, as: :text, sortable: true
    field :slug, as: :text, readonly: true
    field :forum_category, as: :belongs_to, searchable: true
    field :user, as: :belongs_to, searchable: true

    field :pinned, as: :boolean, sortable: true
    field :solved, as: :boolean, sortable: true
    field :forum_posts_count, as: :number, readonly: true, label: "Posts count"

    field :created_at, as: :date_time, readonly: true, sortable: true
    field :updated_at, as: :date_time, readonly: true, sortable: true

    field :forum_posts, as: :has_many
    field :forum_subscriptions, as: :has_many
  end

  def filters
    filter Avo::Filters::ForumThreadSolved
  end
end
