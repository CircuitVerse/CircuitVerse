class RemoveActvityNotificationsTables < ActiveRecord::Migration[7.0]
  def change
    drop_table :notifications
    drop_table :subscriptions
  end
end
