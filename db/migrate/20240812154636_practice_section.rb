class PracticeSection < ActiveRecord::Migration[7.0]
  
  def change
    create_table :question_categories do |t|
      t.string :name
      t.timestamps
    end
    create_table :questions do |t|
      t.string :heading
      t.text :statement
      t.references :category, null: false, foreign_key: { to_table: :question_categories }
      t.jsonb :test_data
      t.jsonb :circuit_boilerplate
      t.string :qid
      t.integer :difficulty_level, default: 0, null: false
      t.timestamps
    end
    safety_assured{
    change_table :users do |t|
      t.jsonb :submission_history, default: [], array: true
      t.boolean :public, default: true
      t.boolean :question_bank_moderator, default: false
    end
    }
  end
end
