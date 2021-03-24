# frozen_string_literal: true

class Api::V1::GroupSerializer
  include FastJsonapi::ObjectSerializer

  attributes :member_count do |group|
    group.group_members.size
  end

  attributes :primary_mentor_name do |group|
    group.primary_mentor.name
  end

  attributes :name, :primary_mentor_id, :created_at, :updated_at

  has_many :group_members
  has_many :assignments
end
