class AddLisOutcomeServiceUrlToAssignments < ActiveRecord::Migration[8.1]
  def change
    add_column :assignments, :lis_outcome_service_url, :string unless column_exists?(:assignments, :lis_outcome_service_url)
  end
end
