# frozen_string_literal: true

class Api::V1::GroupSerializer
  include FastJsonapi::ObjectSerializer

  attributes :member_count do |group|
    group.group_members.size
  end

  attributes :owner_name do |group|
    group.owner.name
  end

  attributes :name, :owner_id, :created_at, :updated_at

  has_many :group_members
  has_many :assignments
end
