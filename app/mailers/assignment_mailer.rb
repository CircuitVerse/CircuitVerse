# frozen_string_literal: true

class AssignmentMailer < ApplicationMailer
  def new_assignment_email(user, assignment)
    return if user.opted_out?

    @assignment = assignment
    @user = user
    mail(to: @user.email, subject: I18n.t("assignment_mailer.subject.new_assignment", group: Group.find_by(id: @assignment.group_id).name))
  end

  def update_assignment_email(user, assignment)
    return if user.opted_out?

    @assignment = assignment
    @user = user
    mail(to: @user.email, subject: I18n.t("assignment_mailer.subject.assignment_updated", group: Group.find_by(id: @assignment.group_id).name))
  end
end
