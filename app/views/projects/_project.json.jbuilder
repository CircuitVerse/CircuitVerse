# frozen_string_literal: true

json.extract! project, :id, :name, :author_id, :forked_project_id, :project_access_type, :data, :created_at, :updated_at
json.url project_url(project, format: :json)
