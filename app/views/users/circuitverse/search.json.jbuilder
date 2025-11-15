# frozen_string_literal: true

json.array! @results do |user|
  json.extract! user, :id, :name
  json.url user_projects_url(id: user.id)
end
