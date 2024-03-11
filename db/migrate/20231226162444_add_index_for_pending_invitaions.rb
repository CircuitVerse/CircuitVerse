class AddIndexForPendingInvitaions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :pending_invitations, :email, algorithm: :concurrently
  end
end
