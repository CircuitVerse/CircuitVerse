class AddLocationToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :location, :string unless column_exists?(:organizations, :location)
  end
end
