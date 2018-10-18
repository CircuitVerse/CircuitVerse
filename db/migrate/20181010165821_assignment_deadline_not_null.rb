class AssignmentDeadlineNotNull < ActiveRecord::Migration[5.1]
  def change
    change_column :assignments, :deadline, :datetime, null: false
  end
end
