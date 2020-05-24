# frozen_string_literal: true

json.extract! assignment, :id, :name, :deadline, :description, :created_at, :updated_at
json.url group_assignment_path(assignment.group, assignment, format: :json)
