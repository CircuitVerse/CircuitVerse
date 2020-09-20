# frozen_string_literal: true

json.extract! group, :id, :name, :owner_id, :created_at, :updated_at
json.url group_url(group, format: :json)
