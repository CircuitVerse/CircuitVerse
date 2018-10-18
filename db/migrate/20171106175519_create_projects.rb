class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.references :author
      t.references :forked_project
      t.string :project_access_type
      t.text :data

      t.timestamps
    end
    add_foreign_key :projects, :users, column: :author_id
    add_foreign_key :projects, :projects, column: :forked_project_id
  end
end
