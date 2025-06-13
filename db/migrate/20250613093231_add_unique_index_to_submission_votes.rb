class AddUniqueIndexToSubmissionVotes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :submission_votes,
              %i[user_id submission_id contest_id],
              unique: true,
              algorithm: :concurrently,
              name: "index_unique_submission_votes"
  end

  def down
    remove_index :submission_votes, name: "index_unique_submission_votes"
  end
end