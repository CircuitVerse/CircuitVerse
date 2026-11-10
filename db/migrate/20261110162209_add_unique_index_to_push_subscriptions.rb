# frozen_string_literal: true

class AddUniqueIndexToPushSubscriptions < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    # Keep the newest row per (user_id, endpoint); rows with NULLs never match, so they are untouched
    safety_assured do
      execute <<~SQL.squish
        DELETE FROM push_subscriptions a
        USING push_subscriptions b
        WHERE a.user_id = b.user_id
          AND a.endpoint = b.endpoint
          AND a.id < b.id
      SQL
    end

    add_index :push_subscriptions, %i[user_id endpoint], unique: true, algorithm: :concurrently
  end

  def down
    remove_index :push_subscriptions, column: %i[user_id endpoint], algorithm: :concurrently
  end
end
