# frozen_string_literal: true

class Api::V1::GroupSerializer
  include FastJsonapi::ObjectSerializer

  attributes :member_count do |group|
    group.group_members.size
  end

  attributes :mentor_name do |group|
    group.mentor.name
  end

  attributes :name, :mentor_id, :lmstype, :created_at, :updated_at

  has_many :group_members
  has_many :assignments
end
