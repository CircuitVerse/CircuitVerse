class AddGdprConfirmationCheckToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :privacy_confirmation, :boolean, default: false
  end
end
