class CreateNoticedNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :noticed_notifications do |t|
      t.references :recipient, polymorphic: true, null: false
      t.string :type, null: false
      t.jsonb :params
      t.datetime :read_at

      t.timestamps
    end
    add_index :noticed_notifications, :read_at
  end
end
