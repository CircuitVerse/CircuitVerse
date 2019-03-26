json.extract! assignment, :id, :name, :deadline, :description, :created_at, :updated_at
json.url group_assignment_url(assignment, format: :json)
