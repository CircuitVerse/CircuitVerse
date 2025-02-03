class CreateGroups < ActiveRecord::Migration[5.1]
  def change
    create_table :groups do |t|
      t.string :name
      t.references :mentor

      t.timestamps
    end
    add_foreign_key :groups, :users, column: :mentor_id
  end
end
