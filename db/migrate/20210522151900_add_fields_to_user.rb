class AddFieldsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :isMoodleGranted, :boolean
  end
end
