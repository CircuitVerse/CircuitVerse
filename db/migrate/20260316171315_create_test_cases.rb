class CreateTestCases < ActiveRecord::Migration[8.0]
  def change
    create_table :test_cases do |t|
      t.references :assignment, null: false, foreign_key: true
      t.text :input
      t.text :expected_output
      t.string :description

      t.timestamps
    end
  end
end
