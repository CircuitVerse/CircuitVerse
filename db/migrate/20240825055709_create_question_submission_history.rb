class CreateQuestionSubmissionHistory < ActiveRecord::Migration[7.0]
  def change
    create_table :question_submission_history do |t|
      t.references :user, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.jsonb :circuit_boilerplate, default: {}
      t.string :status, null: false, default: "unattempted"

      t.timestamps
    end
  end
end
