class AddTestSetFkToAssignments < ActiveRecord::Migration[6.0]
  def change
    add_foreign_key :assignments, :test_sets, validate: false 
  end
end