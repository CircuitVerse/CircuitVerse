# frozen_string_literal: true

class AssignmentPolicy < ApplicationPolicy
  attr_reader :user, :assignment

  def initialize(user, assignment)
    super
    @user = user
    @assignment = assignment
  end

  def show?
    assignment.group.primary_mentor_id == user.id || user.groups.exists?(id: assignment.group.id) \
    || user.admin?
  end

  def admin_access?
    (assignment.group&.primary_mentor_id == user.id) || user.admin?
  end

  def mentor_access?
    assignment.group&.group_members&.exists?(user_id: user.id, mentor: true) || admin_access?
  end

  def start?
    # assignment should not be closed and user should have access to the assignment
    # If a project already exists, the controller will find and redirect to it
    assignment.status != "closed" && show?
  end

  def edit?
    assignment.status != "closed"
  end

  def reopen?
    raise CustomAuthError, "Project is already open" if assignment.status == "open"

    true
  end

  def close?
    (assignment.group&.primary_mentor_id == user.id) || user.admin?
  end

  def can_be_graded?
    mentor_access? && assignment.graded? && (assignment.deadline - Time.current).negative?
  end

  def show_grades?
    assignment.graded? && Time.current > assignment.deadline
  end
end
