class AssignmentDeadlineSubmissionJob < ApplicationJob
  queue_as :default

  def perform(assignment_id)
    assignment = Assignment.find_by(id:assignment_id)
    @projects_submitted = 0
    @projects_not_submitted = 0

    if(assignment.nil? or assignment.status == "closed")
      return
    end

    assignment.with_lock do
      if(assignment.nil? or assignment.status == "closed")
        return
      end

      if Time.now - assignment.deadline >= -10

        if assignment.status == 'open'
          assignment.projects.each do |proj|
            if proj.project_submission == false
              @projects_not_submitted += 1
              submission = proj.dup
              submission.project_submission=true
              submission.forked_project_id = proj.id
              proj.assignment_id=nil
              proj.save!
              submission.save!
            else
              @projects_submitted += 1
            end
          end
          assignment.status = 'closed'
          assignment.save!
          @asign = assignment
          @asg_mail = AssignmentMailer
          @asgn = @asg_mail.deadline_assignment_email(@asign, @projects_submitted, @projects_not_submitted)
          @asgn.deliver_later
        end
      end
    end
  end
end
