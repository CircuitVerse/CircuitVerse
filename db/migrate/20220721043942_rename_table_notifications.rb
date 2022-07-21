class RenameTableNotifications < ActiveRecord::Migration[7.0]
  def self.up
    rename_table :notifications, :old_notifications
  end

  def self.down
    rename_table :old_notifications, :notifications
  end
end
