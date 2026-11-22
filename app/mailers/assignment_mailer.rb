# frozen_string_literal: true

class AssignmentMailer < ApplicationMailer
  def new_assignment_email(user, assignment)
    @user = user.is_a?(User) ? user : User.find_by(id: user)
    @assignment = assignment.is_a?(Assignment) ? assignment : Assignment.find_by(id: assignment)
    return unless @user && @assignment && !@user.opted_out?

    @group = @assignment.group
    mail(to: [@user.email],
         subject: "New Assignment in #{@group&.name}")
  end

  def update_assignment_email(user, assignment)
    @user = user.is_a?(User) ? user : User.find_by(id: user)
    @assignment = assignment.is_a?(Assignment) ? assignment : Assignment.find_by(id: assignment)
    return unless @user && @assignment && !@user.opted_out?

    @group = @assignment.group
    mail(to: [@user.email],
         subject: "Assignment Updated in #{@group&.name}")
  end
end
