class AddAssignmentSubmissionToProject < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :assignment_submission,:boolean,default:false
  end
end
