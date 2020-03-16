# frozen_string_literal: true

class AssignmentMailerPreview < ActionMailer::Preview
  def new_assignment_email
    AssignmentMailer.new_assignment_email(User.first, Assignment.first)
  end

  def update_assignment_email
    AssignmentMailer.update_assignment_email(User.first, Assignment.first)
  end
end
