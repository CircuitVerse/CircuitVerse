class CreatePushSubscriptions < ActiveRecord::Migration[6.0]
  def change
    create_table :push_subscriptions do |t|
      t.string :endpoint
      t.string :p256dh
      t.string :auth
      t.references :user

      t.timestamps
    end
  end
end
