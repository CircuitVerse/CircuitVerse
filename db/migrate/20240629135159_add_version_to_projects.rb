class AddVersionToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :version, :string, default: "v0", null: false
  end
end
