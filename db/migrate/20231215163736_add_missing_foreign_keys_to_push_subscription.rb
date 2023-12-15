class AddMissingForeignKeysToPushSubscription < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :push_subscriptions, :users, column: :user_id, validate: false
  end
end

class ValidateAddMissingForeignKeysToPushSubscription < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :push_subscriptions, :users
  end
end
