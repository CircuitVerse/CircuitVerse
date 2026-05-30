class AddMigrationColumn < ActiveRecord::Migration[7.0]
  def change
    add_column :notifications, :migrated, :boolean, :default => false
  end
end
