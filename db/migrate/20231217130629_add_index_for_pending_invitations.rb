class AddIndexForPendingInvitations < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  
  def change
    remove_index :pending_invitations, name: "index_pending_invitations_on_group_id_and_email" if index_exists?(:pending_invitations, [:group_id, :email])
    remove_index :pending_invitations, :group_id, name: "index_pending_invitations_on_group_id" if index_exists?(:pending_invitations, :group_id)
    add_index :pending_invitations, :group_id, unique: true, algorithm: :concurrently
    add_index :pending_invitations, :email, unique: true, algorithm: :concurrently
  end
end
