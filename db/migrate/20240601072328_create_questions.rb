class CreateQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :questions do |t|
      t.string :heading
      t.text :statement
      t.references :category, null: false, foreign_key: true
      t.references :difficulty_level, null: false, foreign_key: true
      t.jsonb :test_data
      t.jsonb :circuit_boilerplate

      t.timestamps
    end
  end
end
