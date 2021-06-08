class ValidateAddTestSetFkToAssignments < ActiveRecord::Migration[6.0]
  def change
    validate_foreign_key :assignments, :test_sets
  end
end
