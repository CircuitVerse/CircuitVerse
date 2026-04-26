class AddUniqueIndexToCollaborations < ActiveRecord::Migration[7.0]
  # We must disable the DDL transaction for concurrent indexes
  disable_ddl_transaction!

  def change
    add_index :collaborations, [:user_id, :project_id], 
              unique: true, 
              name: "index_collaborations_on_user_id_and_project_id", 
              algorithm: :concurrently
  end
end