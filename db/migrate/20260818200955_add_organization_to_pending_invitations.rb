class AddOrganizationToPendingInvitations < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_reference :pending_invitations, :organization, null: true, index: { algorithm: :concurrently }
    add_column :pending_invitations, :role, :integer
    safety_assured { change_column_null :pending_invitations, :group_id, true }
  end
end