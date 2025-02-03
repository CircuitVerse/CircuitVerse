class AddGrades < ActiveRecord::Migration[5.1]
  def change
    create_table :grades do |t|
      t.string :grade
      t.timestamps
    end

    add_reference :grades, :project, foreign_key: true, on_delete: :cascade
    add_reference :grades, :user, foreign_key: true
    add_reference :grades, :assignment, foreign_key: true, on_delete: :cascade
  end
end
