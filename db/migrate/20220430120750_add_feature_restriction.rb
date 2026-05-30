class AddFeatureRestriction < ActiveRecord::Migration[6.1]
  def change
    add_column :assignments, :feature_restrictions, :jsonb, default: {}
  end
end
