class CreateAssignments < ActiveRecord::Migration[5.1]
  def change
    create_table :assignments do |t|
      t.string :name
      t.references :mentor
      t.timestamp :deadline
      t.text :description

      t.timestamps
    end
    add_foreign_key :assignments, :users, column: :mentor_id
  end
end
