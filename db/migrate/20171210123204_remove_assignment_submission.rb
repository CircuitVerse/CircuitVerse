class RemoveAssignmentSubmission < ActiveRecord::Migration[5.1]
  def change
    remove_column :projects, :assignment_submission,:boolean,default:false
  end
end
