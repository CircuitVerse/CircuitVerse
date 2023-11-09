class CreateAssignmentSubmissions < ActiveRecord::Migration[5.1]
  def change
    create_table :assignment_submissions do |t|
      t.references :assignment, foreign_key: true
      t.references :user, foreign_key: true
      t.string :feedback
      t.integer :grade

      t.timestamps
    end
  end
end
