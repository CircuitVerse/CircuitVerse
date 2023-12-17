class AddIndexForForumThreads < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  
  def change
    add_index :forum_threads, :user_id, unique: true, algorithm: :concurrently
  end
end
