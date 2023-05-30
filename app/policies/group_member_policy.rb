# frozen_string_literal: true

class GroupMemberPolicy < ApplicationPolicy
  # @return [User]
  attr_reader :user
  # @return [GroupMember]
  attr_reader :group_member

  # @param [User] user
  # @param [GroupMember] group_member
  def initialize(user, group_member)
    @user = user
    @group_member = group_member
  end

  # Check if user is primary mentor of the group
  # @return [Boolean]
  def primary_mentor?
    (group_member.group.primary_mentor_id == user.id || user.admin?)
  end

  # Check if user is a mentor of the group
  # @return [Boolean]
  def mentor?
    (group_member.group.group_members.exists?(user_id: user.id, mentor: true) || primary_mentor?)
  end
end
