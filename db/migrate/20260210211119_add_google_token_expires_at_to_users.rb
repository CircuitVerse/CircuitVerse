class AddGoogleTokenExpiresAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :google_token_expires_at, :datetime
  end
end
