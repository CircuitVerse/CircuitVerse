# frozen_string_literal: true

class AssignmentMailer < ApplicationMailer
  def new_assignment_email(user, assignment)
    @assignment = assignment
    @user = user
    mail_if_subscribed(@user.email,
                       "New Assignment in #{Group.find_by(id: @assignment.group_id).name}", user)
  end

  def update_assignment_email(user, assignment)
    @assignment = assignment
    @user = user
    mail_if_subscribed(@user.email,
                       "Assignment Updated in #{Group.find_by(id: @assignment.group_id).name}", user)
  end
end
