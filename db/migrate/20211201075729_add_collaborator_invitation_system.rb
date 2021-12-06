class AddCollaboratorInvitationSystem < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  def change
    add_column :projects, :collaboration_token, :string 
    add_column :projects, :token_expires_at, :datetime
    add_index :projects, :collaboration_token, unique: true, algorithm: :concurrently
  end
end
