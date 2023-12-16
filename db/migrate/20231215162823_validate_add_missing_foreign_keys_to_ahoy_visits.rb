class ValidateAddMissingForeignKeysToAhoyVisits < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :ahoy_visits, :users
  end
end
