class AddOnDeleteToUserForeignKeys < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :forum_subscriptions, :users
    add_foreign_key :forum_subscriptions, :users, on_delete: :nullify, validate: false

    remove_foreign_key :group_members, :users
    add_foreign_key :group_members, :users, on_delete: :nullify, validate: false

    remove_foreign_key :collaborations, :users
    add_foreign_key :collaborations, :users, on_delete: :nullify, validate: false

    remove_foreign_key :forum_threads, :users
    add_foreign_key :forum_threads, :users, on_delete: :nullify, validate: false

    remove_foreign_key :forum_posts, :users
    add_foreign_key :forum_posts, :users, on_delete: :nullify, validate: false

    remove_foreign_key :stars, :users
    add_foreign_key :stars, :users, on_delete: :nullify, validate: false

    remove_foreign_key :submissions, :users
    add_foreign_key :submissions, :users, on_delete: :nullify, validate: false

    remove_foreign_key :submission_votes, :users
    add_foreign_key :submission_votes, :users, on_delete: :nullify, validate: false
  end
end
