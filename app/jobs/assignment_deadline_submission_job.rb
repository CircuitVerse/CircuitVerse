class AssignmentDeadlineSubmissionJob < ApplicationJob
  queue_as :default

  def perform(assignment_id)
    assignment = Assignment.find_by(id:assignment_id)
    @projectsSubmitted = 0
    @projectsNotSubmitted = 0

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
	      @projectsNotSubmitted = @projectsNotSubmitted + 1
              submission = proj.dup
              submission.project_submission=true
              submission.forked_project_id = proj.id
              proj.assignment_id=nil
              proj.save!
              submission.save!
	    else
	      @projectsSubmitted = @projectsSubmitted + 1
            end
          end
          assignment.status = 'closed'
          assignment.save!
          AssignmentMailer.deadline_assignment_email(assignment, @projectsSubmitted, @projectsNotSubmitted).deliver_later
        end


      end

    end



  end
end
