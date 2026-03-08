class CreateSubgroups < ActiveRecord::Migration[8.0]
  def change
    create_table :subgroups do |t|
      t.string :name
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
