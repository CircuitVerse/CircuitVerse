class AddVersionToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :version, :string, default: "1.0", null: false
  end
end
