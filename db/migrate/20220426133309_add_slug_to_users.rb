class AddSlugToUsers < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  def change
    add_column :users, :slug, :string
    add_index :users, :slug, unique: true, algorithm: :concurrently
  end
end
