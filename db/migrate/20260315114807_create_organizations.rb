class CreateOrganizations < ActiveRecord::Migration[7.0]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.timestamps
    end
    add_index :organizations, :slug, unique: true
  end
end
