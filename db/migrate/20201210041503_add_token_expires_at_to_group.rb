class AddTokenExpiresAtToGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :token_expires_at, :datetime
  end
end
