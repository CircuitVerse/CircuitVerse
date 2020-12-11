class AddGroupTokenToGroup < ActiveRecord::Migration[6.0]
  def change
    add_column :groups, :group_token, :string
    add_index :groups, :group_token, unique: true
  end
end
