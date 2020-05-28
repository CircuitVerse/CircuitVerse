# frozen_string_literal: true

class Api::V1::ProjectSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :project_access_type, :created_at,
             :updated_at, :image_preview, :description,
             :view, :tags

  attributes :stars_count do |project|
    project.stars.count
  end

  belongs_to :author
end
