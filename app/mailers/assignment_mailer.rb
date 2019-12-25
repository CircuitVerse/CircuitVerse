class AssignmentMailer < ApplicationMailer
  def new_assignment_email(user , assignment)
    @assignment = assignment
    @user = user
    mail(to: @user.email, subject: "New Assignment in " +  Group.find_by(id:(@assignment.group_id)).name )
  end
  def update_assignment_email(user,  assignment)

    @assignment = assignment
    @user = user
    mail(to: (@user.email), subject: "Assignment Updated in " +  Group.find_by(id:(@assignment.group_id)).name )
  end
  def deadline_assignment_email(assignment)
    @assignment = assignment
    @user = User.find_by(id:Group.find_by(id:@assignment.group_id).mentor_id).name
    mail(to: (@user.email), subject: "Assignment has reached the deadline in " +  Group.find_by(id:(@assignment.group_id)).name )
  end
end
