class ModifyIndexForGrades < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    remove_index :grades, name: "index_grades_on_assignment_id" if index_exists?(:grades, :assignment_id)
    remove_index :grades, name: "index_grades_on_project_id_and_assignment_id" if index_exists?(:grades, [:project_id, :assignment_id])
    remove_index :grades, :project_id, name: "index_grades_on_project_id" if index_exists?(:grades, :project_id)
    add_index :grades, :project_id, unique: true, algorithm: :concurrently
    add_index :grades, :assignment_id, unique: true, algorithm: :concurrently
  end
end
