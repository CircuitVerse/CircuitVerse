class AddSlugToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :slug, :string
    add_index :projects, :slug, unique: true
  end
end
