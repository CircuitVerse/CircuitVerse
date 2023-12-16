class ValidateAddMissingForeignKeysToPushSubscription < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :push_subscriptions, :users
  end
end
