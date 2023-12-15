class AddMissingForeignKeysToAhoyVisits < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :ahoy_visits, :users, column: :user_id, validate: false
  end
end

class ValidateAddMissingForeignKeysToAhoyVisits < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :ahoy_visits, :users
  end
end
