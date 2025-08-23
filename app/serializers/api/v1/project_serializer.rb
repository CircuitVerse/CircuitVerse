# frozen_string_literal: true

class Api::V1::ProjectSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :project_access_type, :created_at,
             :updated_at, :description,
             :view, :tags

  attributes :is_starred do |project, params|
    if params[:current_user].nil?
      nil
    else
      Star.exists?(user_id: params[:current_user].id, project_id: project.id)
    end
  end

  attributes :author_name do |project|
    project.author.name
  end

  attributes :stars_count do |project|
    project.stars_count
  end

  attributes :thread_id do |project|
    project.commontator_thread.id
  end

  attributes :is_thread_subscribed do |project, params|
    if params[:current_user].nil?
      nil
    else
      params[:current_user].commontator_subscriptions.exists?(
        thread_id: project.commontator_thread.id
      )
    end
  end

  attributes :is_thread_closed do |project|
    project.commontator_thread.is_closed?
  end

  # :nocov:
  attributes :image_preview do |project|
    if project.circuit_preview.attached?
      {
        url: Rails.application.routes.url_helpers.rails_blob_url(project.circuit_preview, only_path: true)
      }
    else
      {
        url: ActionController::Base.helpers.asset_path("empty_project/default.png")
      }
    end
  end
  # :nocov:

  belongs_to :author
  has_many :collaborators, serializer: Api::V1::UserSerializer
end
