class ProjectAssignmentForeignKey < ActiveRecord::Migration[5.1]
  def change
    add_reference :projects, :assignment, foreign_key: true
  end
end
