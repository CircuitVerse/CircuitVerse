class RemoveFeatureRestrictionsIndexColumn < ActiveRecord::Migration[6.1]
  def self.up
    remove_index :assignments, name: "index_assignments_on_feature_restrictions"
  end

  def self.down
    remove_index :assignments, name: "index_assignments_on_feature_restrictions"
  end
end
