class AddGradesPublishedToAssignments < ActiveRecord::Migration[6.1]
  def change
    add_column :assignments, :grades_published, :boolean, :default => false
  end
end
