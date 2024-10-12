class CreateQuestionSubmissionHistory < ActiveRecord::Migration[6.1]
  def change
    create_table :question_submission_history do |t|
      t.references :user, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.jsonb :circuit_boilerplate, default: {}
      t.string :status, null: false, default: "unattempted"

      t.timestamps
    end

    add_index :question_submission_history, [:question_id, :user_id], unique: true, name: 'index_question_submission_history_on_question_and_user'
  end
end
