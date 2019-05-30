class AddGrades < ActiveRecord::Migration[5.1]
  def change
    create_table :grades do |t|
      t.string :grade
      t.integer :grading_scale
      t.timestamps
    end

    add_reference :grades, :project, foreign_key: true
    add_reference :grades, :user, foreign_key: true
    add_reference :grades, :assignment, foreign_key: true
    add_column :assignments, :grading_scale, :integer, default: 0
  end
end
