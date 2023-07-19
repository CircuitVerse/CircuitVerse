# frozen_string_literal: true

class AssignmentPolicy < ApplicationPolicy
  # @return [User]
  attr_reader :user
  # @return [Assignment]
  attr_reader :assignment

  # @param [User] user
  # @param [Assignment] assignment
  def initialize(user, assignment)
    super
    @user = user
    @assignment = assignment
  end

  # @return [Boolean]
  def show?
    assignment.group.primary_mentor_id == user.id || user.groups.exists?(id: assignment.group.id) \
    || user.admin?
  end

  # Check if user has admin access to the assignment
  # @return [Boolean]
  def admin_access?
    (assignment.group&.primary_mentor_id == user.id) || user.admin?
  end

  # Check if user has mentor access to the assignment
  # @return [Boolean]
  def mentor_access?
    assignment.group&.group_members&.exists?(user_id: user.id, mentor: true) || admin_access?
  end

  # @return [Boolean]
  def start?
    # assignment should not be closed and not submitted
    assignment.status != "closed" \
      && !Project.exists?(author_id: user.id, assignment_id: assignment.id)
  end

  # @return [Boolean]
  def edit?
    assignment.status != "closed"
  end

  # @return [Boolean]
  def reopen?
    raise CustomAuthError, "Project is already open" if assignment.status == "open"

    true
  end

  # @return [Boolean]
  def close?
    (assignment.group&.primary_mentor_id == user.id) || user.admin?
  end

  # @return [Boolean]
  def can_be_graded?
    mentor_access? && assignment.graded? && (assignment.deadline - Time.current).negative?
  end

  # @return [Boolean]
  def show_grades?
    assignment.graded? && Time.current > assignment.deadline
  end
end
