# frozen_string_literal: true

class GroupMentorPolicy < ApplicationPolicy
  attr_reader :user, :group_mentor

  def initialize(user, group_mentor)
    @user = user
    @group_mentor = group_mentor
  end

  def owner?
    (group_mentor.group.owner_id == user.id || user.admin?)
  end
end
