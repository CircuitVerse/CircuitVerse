class AddCascadePropertyToForumAssociatedFk < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :forum_posts, :users
    remove_foreign_key :forum_threads, :users
  
    add_foreign_key :forum_posts, :users, on_delete: :cascade
    add_foreign_key :forum_threads, :users, on_delete: :cascade
  end
end
