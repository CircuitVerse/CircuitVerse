class AddIndexForForumSubscriptions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!
  
  def change
    add_index :forum_subscriptions, :user_id, algorithm: :concurrently
  end
end
