class AddBannedToUsers < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :users, :banned, :boolean, default: false, null: false
    add_index :users, :banned, algorithm: :concurrently
  end
end
