# This migration comes from simple_discussion (originally 20170417012933)
class CreateForumSubscriptions < ActiveRecord::Migration[4.2]
  def change
    create_table :forum_subscriptions do |t|
      t.references :forum_thread, foreign_key: true
      t.references :user, foreign_key: true
      t.string   :subscription_type

      t.timestamps
    end
  end
end
