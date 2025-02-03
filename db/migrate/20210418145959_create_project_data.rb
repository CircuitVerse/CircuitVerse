class CreateProjectData < ActiveRecord::Migration[6.0]
  def change
    create_table :project_data do |t|
      t.references :project, null: false, foreign_key: true, index: {unique: true}
      t.text :data

      t.timestamps
    end
  end
end
