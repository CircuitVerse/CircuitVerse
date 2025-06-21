# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  # @return [User]
  attr_reader :user
  # @return [Group]
  attr_reader :group

  # @param [User] user
  # @param [Group] group
  def initialize(user, group)
    @user = user
    @group = group
    @admin_access = ((group.primary_mentor_id == user.id) || user.admin?)
  end

  # return [Boolean]
  def show_access?
    @admin_access || group.group_members.exists?(user_id: user.id)
  end

  # return [Boolean]
  def admin_access?
    @admin_access
  end

  # return [Boolean]
  def mentor_access?
    @admin_access || @group.group_members.exists?(user_id: user.id, mentor: true)
  end
end
