class ModifyIndexForGrades < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  
  def change
    remove_index :grades, :project_id, name: "index_grades_on_project_id" if index_exists?(:grades, :project_id)
    add_index :grades, :project_id, unique: true, algorithm: :concurrently
  end
end
