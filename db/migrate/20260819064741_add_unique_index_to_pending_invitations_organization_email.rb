class AddUniqueIndexToPendingInvitationsOrganizationEmail < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :pending_invitations, [:organization_id, :email],
              unique: true, algorithm: :concurrently,
              name: "index_pending_invitations_on_organization_id_and_email"
  end
end
