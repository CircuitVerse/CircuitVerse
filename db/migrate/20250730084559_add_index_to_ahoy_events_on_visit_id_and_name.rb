class AddIndexToAhoyEventsOnVisitIdAndName < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_index :ahoy_events, [:visit_id, :name], algorithm: :concurrently
  end
end
