# frozen_string_literal: true

class AssignmentPolicy < ApplicationPolicy
  attr_reader :user, :assignment

  def initialize(user, assignment)
    @user = user
    @assignment = assignment
  end

  def show?
    assignment.group.mentor_id == user.id || user.groups.pluck(:id).include?(assignment.group.id) \
    || user.admin?
  end

  def admin_access?
    (assignment.group&.mentor_id == user.id) || user.admin?
  end

  def start?
    # assignment should not be closed and not submitted
    assignment.status != "closed" \
      && Project.find_by(author_id: user.id, assignment_id: assignment.id).nil?
  end

  def edit?
    assignment.status != "closed"
  end

  def reopen?
    raise CustomAuthError.new("Project is already open") if assignment.status == "open"
    true
  end

  def can_be_graded?
    admin_access? && assignment.graded? && assignment.deadline - Time.current < 0
  end

  def show_grades?
    assignment.graded? && Time.current > assignment.deadline
  end
end
