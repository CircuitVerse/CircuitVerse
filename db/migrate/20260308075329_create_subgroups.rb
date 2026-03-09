class CreateSubgroups < ActiveRecord::Migration[7.0]
  def change
    create_table :subgroups do |t|
      t.string :name, null: false
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
