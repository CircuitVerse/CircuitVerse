# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  attr_reader :user, :group

  def initialize(user, group)
    @user = user
    @group = group
    @admin_access = ((group.owner_id == user.id) || user.admin?)
    @mentor_access = (group.group_mentors.exists?(user_id: user.id))
  end

  def show_access?
    @admin_access || group.group_members.exists?(user_id: user.id) || group.group_mentors.exists?(user_id: user.id)
  end

  def admin_access?
    @admin_access
  end

  def mentor_access?
    @mentor_access
  end
end
