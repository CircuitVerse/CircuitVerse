class AddInviteTokenIndexToOrganizations < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :organizations, :invite_token, unique: true, algorithm: :concurrently
  end
end