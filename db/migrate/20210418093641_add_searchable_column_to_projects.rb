class AddSearchableColumnToProjects < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!
  def change
    add_column :projects, :searchable, :tsvector
    add_index :projects, :searchable, using: :gin, algorithm: :concurrently
  end
end
