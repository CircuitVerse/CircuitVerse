class ValidateUserForeignKeys < ActiveRecord::Migration[6.1]
  def change
    validate_foreign_key :forum_subscriptions, :users
    validate_foreign_key :group_members, :users
    validate_foreign_key :collaborations, :users
    validate_foreign_key :forum_threads, :users
    validate_foreign_key :forum_posts, :users
    validate_foreign_key :stars, :users
    validate_foreign_key :submissions, :users
    validate_foreign_key :submission_votes, :users
  end
end
