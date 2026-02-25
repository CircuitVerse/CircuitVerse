# frozen_string_literal: true

class Avo::Resources::ForumThread < Avo::BaseResource
  self.title = :title
  self.includes = %i[forum_category user forum_posts]
  self.model_class = ::ForumThread

  def fields
    basic_fields
    content_fields
    status_fields
    timestamp_fields
    relationship_fields
  end

  private

    def basic_fields
      field :id, as: :id, link_to_resource: true
      field :forum_category, as: :belongs_to, searchable: true
      field :user, as: :belongs_to, searchable: true
    end

    def content_fields
      field :title, as: :text, sortable: true
      field :slug, as: :text
    end

    def status_fields
      field :forum_posts_count, as: :number, label: "Posts count"
      field :pinned, as: :boolean, sortable: true
      field :solved, as: :boolean, sortable: true
    end

    def timestamp_fields
      field :created_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
      field :updated_at, as: :date_time, readonly: true, sortable: true, hide_on: %i[new edit]
    end

    def relationship_fields
      field :forum_posts, as: :has_many
      field :forum_subscriptions, as: :has_many
      field :optin_subscribers, as: :has_many, name: "Optin Subscribers"
      field :optout_subscribers, as: :has_many, name: "Optout Subscribers"
      field :users, as: :has_many
    end
end
