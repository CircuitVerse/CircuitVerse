class AssignmentPolicy < ApplicationPolicy
  attr_reader :user, :assignment

  def initialize(user, assignment)
    @user = user
    @assignment = assignment
  end

  def admin_access?
    (assignment.group&.mentor_id == user.id) || user.admin?
  end

  def start?
    # assignment should not be closed and not submitted
    assignment.status != 'closed' && Project.find_by(author_id: user.id, assignment_id: assignment.id).nil?
  end

  def edit?
    assignment.status != 'closed'
  end

  def reopen?
    raise CustomAuthError.new('Project is already open') if assignment.status == 'open'
    true
  end
end
