class AddCompoundIndexToProjects < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :projects, [:project_access_type, :forked_project_id], algorithm: :concurrently
  end
end
