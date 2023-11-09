class AddRefToAssignmentSubmission < ActiveRecord::Migration[5.1]
  def change
    add_reference :assignment_submissions, :project, foreign_key:true
  end
end
