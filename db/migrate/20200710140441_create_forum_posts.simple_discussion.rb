# This migration comes from simple_discussion (originally 20170417012932)
class CreateForumPosts < ActiveRecord::Migration[4.2]
  def change
    create_table :forum_posts do |t|
      t.references :forum_thread, foreign_key: true
      t.references :user, foreign_key: true
      t.text     :body
      t.boolean  :solved, default: false

      t.timestamps
    end
  end
end
