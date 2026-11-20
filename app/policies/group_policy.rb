# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  attr_reader :user, :group

  def initialize(user, group)
    super
    @user = user
    @group = group
  end

  def show_access?
    admin_access? || group.group_members.exists?(user_id: user.id)
  end

  # "admin" here means the group's primary mentor or a site admin.
  def admin_access?
    group.primary_mentor_id == user.id || user.admin?
  end

  def mentor_access?
    admin_access? || group.group_members.exists?(user_id: user.id, mentor: true)
  end

  # Only an instructor (primary or co-mentor) or a site admin may create a
  # subgroup under this group or manage who belongs to one.
  def manage_subgroups?
    mentor_access?
  end
end
