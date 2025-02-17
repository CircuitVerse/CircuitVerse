class AddPartialIndexForUnreadNotifications < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :noticed_notifications, [:recipient_type, :recipient_id], where: 'read_at IS NULL', name: 'idx_noticed_notifications_unread', algorithm: :concurrently
  end

  def down
    remove_index :noticed_notifications, name: 'idx_noticed_notifications_unread'
  end
end
