# frozen_string_literal: true

json.extract! project, :id, :name, :author_id, :forked_project_id, :project_access_type,
              :created_at, :updated_at
json.url user_project_url(project.author, project, format: :json)
