# frozen_string_literal: true

class CreateCommentTables < ActiveRecord::Migration[8.1]
  def change
    create_comment_threads
    create_comments
  end

  private

    def create_comment_threads
      create_table :comment_threads do |t|
        t.references :commentable, polymorphic: true, null: false, index: false
        t.datetime :closed_at
        t.references :closer, null: true, foreign_key: { to_table: :users }

        t.timestamps
      end

      add_index :comment_threads, %i[commentable_type commentable_id],
                unique: true,
                name: "index_comment_threads_on_commentable"
    end

    def create_comments
      create_table :comments do |t|
        t.references :comment_thread, null: false, foreign_key: true, index: false
        t.references :user, null: false, foreign_key: true
        t.references :editor, null: true, foreign_key: { to_table: :users }
        t.references :parent, null: true, foreign_key: { to_table: :comments }
        t.text :body, null: false
        t.datetime :deleted_at

        t.timestamps
      end

      add_index :comments, %i[comment_thread_id created_at]
      add_index :comments, :deleted_at
    end
end
