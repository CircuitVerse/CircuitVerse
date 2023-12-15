class AddMissingForeignKeysToAhoyEvents < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :ahoy_events, :ahoy_visits, column: :visit_id, validate: false
    add_foreign_key :ahoy_events, :users, column: :user_id, validate: false
  end
end

class ValidateAddMissingForeignKeysToAhoyEvents < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :ahoy_events, :ahoy_visits
    validate_foreign_key :ahoy_events, :users
  end
end
