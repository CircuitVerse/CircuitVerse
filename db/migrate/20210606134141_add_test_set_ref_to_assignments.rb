class AddTestSetRefToAssignments < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_reference :assignments, :test_set, index: {algorithm: :concurrently}
  end
end
