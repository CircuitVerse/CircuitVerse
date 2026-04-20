class AddUniqueIndexToCollaborations < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :collaborations,
              [:user_id, :project_id],
              unique: true,
              algorithm: :concurrently
  end
end
