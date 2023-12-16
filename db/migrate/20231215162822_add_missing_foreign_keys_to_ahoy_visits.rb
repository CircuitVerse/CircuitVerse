class AddMissingForeignKeysToAhoyVisits < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :ahoy_visits, :users, column: :user_id, validate: false
  end
end
