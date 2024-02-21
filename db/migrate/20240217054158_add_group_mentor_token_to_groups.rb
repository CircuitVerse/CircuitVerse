class AddGroupMentorTokenToGroups < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  def change
    add_column :groups, :group_mentor_token, :string
    add_column :groups, :mentor_token_expires_at, :datetime ,precision: nil
    add_index :groups, :group_mentor_token, unique: true ,algorithm: :concurrently
  end
end
