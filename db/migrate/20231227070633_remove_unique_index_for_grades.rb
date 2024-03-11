class RemoveUniqueIndexForGrades < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    remove_index :grades, name: "index_grades_on_project_id_and_assignment_id" if index_exists?(:grades, [:project_id, :assignment_id])
    add_index :grades, [:project_id, :assignment_id], algorithm: :concurrently
  end
end
