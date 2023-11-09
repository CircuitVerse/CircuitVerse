# frozen_string_literal: true

class Api::V1::GroupMemberSerializer
  include FastJsonapi::ObjectSerializer

  attributes :group_id, :user_id, :created_at, :updated_at, :mentor

  attribute :name do |object|
    object.user.name
  end

  attribute :email do |object|
    object.user.email
  end
end
