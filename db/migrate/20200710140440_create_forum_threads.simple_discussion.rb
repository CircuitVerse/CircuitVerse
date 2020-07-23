# This migration comes from simple_discussion (originally 20170417012931)
class CreateForumThreads < ActiveRecord::Migration[4.2]
  def change
    create_table :forum_threads do |t|
      t.references :forum_category, foreign_key: true
      t.references :user, foreign_key: true
      t.string :title, null: false
      t.string :slug, null: false
      t.integer :forum_posts_count, default: 0
      t.boolean :pinned, default: false
      t.boolean :solved, default: false

      t.timestamps
    end
  end
end
