class CreateSubmissionVotes < ActiveRecord::Migration[7.0]
  def change
    create_table :submission_votes do |t|
      t.references :contest, foreign_key: true
      t.references :submission, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end