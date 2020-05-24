# frozen_string_literal: true

class Api::V1::GroupSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :mentor_id, :created_at, :updated_at

  has_many :group_members
  has_many :assignments
end
