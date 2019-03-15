# frozen_string_literal: true

class GroupMemberPolicy < ApplicationPolicy
  attr_reader :user, :group_member

  def initialize(user, group_member)
    @user = user
    @group_member = group_member
  end

  def mentor?
    (group_member.group.mentor_id == user.id || user.admin?)
  end
end
