class AddPreferencesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :preferences, :jsonb
  end
end
