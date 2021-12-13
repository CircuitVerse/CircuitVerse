class ChangeUniqueIndexForProjects < ActiveRecord::Migration[6.0]
  def change
    add_index :projects, [:slug, :author_id], unique: true
    remove_index :projects, :slug if index_exists?(:projects, :slug)
  end
end
