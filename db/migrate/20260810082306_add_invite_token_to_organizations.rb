class AddInviteTokenToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :invite_token, :string
    add_column :organizations, :invite_token_expires_at, :datetime
    add_column :organizations, :invite_token_role, :integer
  end
end
