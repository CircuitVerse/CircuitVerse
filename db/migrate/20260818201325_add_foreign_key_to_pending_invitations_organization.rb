class AddForeignKeyToPendingInvitationsOrganization < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :pending_invitations, :organizations, validate: false
  end
end
