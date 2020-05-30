# frozen_string_literal: true

json.extract! collaboration, :id, :user_id, :project_id, :created_at, :updated_at
json.url collaboration_url(collaboration, format: :json)
