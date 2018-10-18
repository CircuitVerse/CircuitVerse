class AddSubmissionBooleanToProject < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :project_submission, :boolean, default: false
  end
end
