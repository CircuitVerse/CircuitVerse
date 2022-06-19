# frozen_string_literal: true

class AssignmentMailer < ApplicationMailer
  def new_assignment_email(user, assignment)
    return if user.opted_out?

    @assignment = assignment
    @user = user
    mail(to: @user.email, subject: "New Assignment in #{Group.find_by(id: @assignment.group_id).name}")
  end

  def update_assignment_email(user, assignment)
    return if user.opted_out?

    @assignment = assignment
    @user = user
    mail(to: @user.email, subject: "Assignment Updated in #{Group.find_by(id: @assignment.group_id).name}")
  end

  def deadline_assignment_email(assignment, student_submission)
    @assignment = assignment
    @student_submission = student_submission
    @group = Group.find_by(id: @assignment.group_id)
    @total_members = @group.group_members.count
    @student_not_submission = @group.group_members.count - @student_submission
    @mentor = @group.mentor
    @pendingInvitation = @group.pending_invitations.count
    mail(to: @mentor.email, subject: "Assignment Deadline has been reached in #{@group.name}")
  end
end
