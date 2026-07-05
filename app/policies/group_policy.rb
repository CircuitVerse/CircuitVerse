# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  attr_reader :user, :group

  def initialize(user, group)
    @user = user
    @group = group
    @admin_access = (group.primary_mentor_id == user.id) || user.admin?
  end

  def show_access?
    @admin_access || group.group_members.exists?(user_id: user.id)
  end

  def admin_access?
    @admin_access
  end

  def mentor_access?
    @admin_access || @group.group_members.exists?(user_id: user.id, mentor: true)
  end

  # Subgroups are managed from their top-level parent by its mentors.
  def manage_subgroups?
    !group.subgroup? && mentor_access?
  end
end
