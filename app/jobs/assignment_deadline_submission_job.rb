class AssignmentDeadlineSubmissionJob < ApplicationJob
  queue_as :default

  def perform(assignment_id)
    assignment = Assignment.find_by(id:assignment_id)

    if(assignment.nil? or assignment.status == "closed")
      return
    end

    assignment.with_lock do

      if(assignment.nil? or assignment.status == "closed")
        return
      end

      if Time.now - assignment.deadline >= -10
        assignment.status = 'closed'
        assignment.save!

        if assignment.status == 'open'
          assignment.projects.each do |proj|
            if proj.project_submission == false
              submission = proj.dup
              submission.project_submission=true
              submission.forked_project_id = proj.id
              proj.assignment_id=nil
              proj.save!
              submission.save!
            end
          end

        end
      end

    end



  end
end
