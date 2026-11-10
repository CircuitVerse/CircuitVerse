# frozen_string_literal: true

class AddUniqueIndexToPushSubscriptions < ActiveRecord::Migration[8.1]
  def up
    # Block writes (reads still work) until this migration commits, so no new duplicate
    # can appear between the cleanup and the unique index build. Everything runs in one
    # transaction, so a failure rolls back and leaves no invalid index behind.
    safety_assured do
      execute "LOCK TABLE push_subscriptions IN SHARE ROW EXCLUSIVE MODE"

      # Keep the newest row per (user_id, endpoint); rows with NULLs never match, so they are untouched
      execute <<~SQL.squish
        DELETE FROM push_subscriptions a
        USING push_subscriptions b
        WHERE a.user_id = b.user_id
          AND a.endpoint = b.endpoint
          AND a.id < b.id
      SQL

      add_index :push_subscriptions, %i[user_id endpoint], unique: true
    end
  end

  def down
    safety_assured do
      remove_index :push_subscriptions, column: %i[user_id endpoint]
    end
  end
end
