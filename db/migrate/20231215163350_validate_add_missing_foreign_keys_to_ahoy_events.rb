class ValidateAddMissingForeignKeysToAhoyEvents < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :ahoy_events, :ahoy_visits
    validate_foreign_key :ahoy_events, :users
  end
end
