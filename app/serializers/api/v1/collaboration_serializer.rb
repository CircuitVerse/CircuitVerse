# frozen_string_literal: true

class Api::V1::CollaborationSerializer
  include FastJsonapi::ObjectSerializer

  attribute :project do |object|
    {
      "id": object.project.id,
      "name": object.project.name
    }
  end

  attribute :user do |object|
    {
      "id": object.user.id,
      "name": object.user.name,
      "email": object.user.email
    }
  end
end
