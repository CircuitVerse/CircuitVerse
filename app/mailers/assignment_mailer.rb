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

  def deadline_assignment_email(assignment, proj_s, proj_ns)
    @assignment = assignment
    @proj_s = proj_s
    @proj_ns = proj_ns
    @user = User.find_by(id: Group.find_by(id: @assignment.group_id).mentor_id)
    @grp_name = Group.find_by(id:(@assignment.group_id)).name
    mail(to: (@user.email), subject: "Assignment has reached the deadline in " + @grp_name)
  end
end
