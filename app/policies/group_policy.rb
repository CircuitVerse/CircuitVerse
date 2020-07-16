# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
  attr_reader :user, :group

  def initialize(user, group)
    @user = user
    @group = group
    @admin_access = ((group.mentor_id == user.id) || user.admin?)
  end

  def check_edit_access?
    ((!user.nil? && group.mentor_id == user.id) \
    || (!user.nil? && Mentorship.exists?(group_id: group.id, user_id: user.id)))
  end

  def show_access?
    @admin_access || group.group_members.exists?(user_id: user.id)
  end

  def admin_access?
    @admin_access
  end
end
