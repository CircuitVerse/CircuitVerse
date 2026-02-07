class AddBannedToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :banned, :boolean, default: false
    add_index :users, :banned
  end
end
