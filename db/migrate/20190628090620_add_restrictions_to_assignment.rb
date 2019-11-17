class AddRestrictionsToAssignment < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :restrictions, :json, default: "[]"
  end
end
