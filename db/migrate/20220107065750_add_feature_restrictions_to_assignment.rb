class AddFeatureRestrictionsToAssignment < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  def change
    add_column :assignments, :feature_restrictions, :jsonb, default: {}
    add_index  :assignments, :feature_restrictions, using: :gin, algorithm: :concurrently
  end
end
