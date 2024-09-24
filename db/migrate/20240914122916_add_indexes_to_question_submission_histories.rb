class AddIndexesToQuestionSubmissionHistories < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    unless index_exists?(:question_submission_histories, :question_id)
      add_index :question_submission_histories, :question_id, algorithm: :concurrently
    end
  end
end
