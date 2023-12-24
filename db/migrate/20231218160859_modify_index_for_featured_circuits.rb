class ModifyIndexForFeaturedCircuits < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    remove_index :featured_circuits, :project_id, name: "index_featured_circuits_on_project_id" if index_exists?(:featured_circuits, :project_id)
    add_index :featured_circuits, :project_id, unique: true, algorithm: :concurrently
  end
end
