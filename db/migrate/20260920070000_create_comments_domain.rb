# frozen_string_literal: true

class CreateCommentsDomain < ActiveRecord::Migration[8.0]
  def change
    create_table :comment_threads do |t|
      t.datetime :closed_at, precision: nil
      t.integer :closer_id
      t.string :closer_type
      t.integer :commontable_id
      t.string :commontable_type
      t.timestamps
    end
    add_index :comment_threads, %i[commontable_id commontable_type], unique: true,
                                                             name: "index_comment_threads_on_commontable"

    create_table :comments do |t|
      t.text :body, null: false
      t.integer :cached_votes_up, default: 0
      t.integer :cached_votes_down, default: 0
      t.integer :creator_id
      t.string :creator_type
      t.datetime :deleted_at, precision: nil
      t.integer :editor_id
      t.string :editor_type
      t.references :thread, null: false, foreign_key: { to_table: :comment_threads }
      t.timestamps
    end
    add_index :comments, :cached_votes_up
    add_index :comments, :cached_votes_down
    add_index :comments, %i[creator_id creator_type thread_id],
                         name: "index_comments_on_creator_and_thread"
    add_index :comments, %i[thread_id created_at]

    create_table :comment_subscriptions do |t|
      t.integer :subscriber_id, null: false
      t.string :subscriber_type, null: false
      t.references :thread, null: false, foreign_key: { to_table: :comment_threads }
      t.timestamps
    end
    add_index :comment_subscriptions, %i[subscriber_id subscriber_type thread_id], unique: true,
                                      name: "index_comment_subscriptions_on_subscriber_and_thread"
  end
end
