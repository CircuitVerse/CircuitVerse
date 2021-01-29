# frozen_string_literal: true

class GroupMemberPolicy < ApplicationPolicy
  attr_reader :user, :group_member

  def initialize(user, group_member)
    @user = user
    @group_member = group_member
  end

  def owner?
  	(group_member.group.owner_id == user.id || user.admin?)
  end

  def mentor?
    (group_member.group.group_members.exists?(user_id: user.id, mentor: true) || owner?)
  end
end
