# frozen_string_literal: true

class AddUniqueIndexToContestWinners < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  INDEX_NAME = :index_contest_winners_on_contest_id

  def up
    remove_index :contest_winners,
                 name:  INDEX_NAME,
                 algorithm: :concurrently,
                 if_exists: true

    add_index    :contest_winners,
                 :contest_id,
                 unique: true,
                 name: INDEX_NAME,
                 algorithm: :concurrently
  end

  def down
    remove_index :contest_winners,
                 name: INDEX_NAME,
                 algorithm: :concurrently,
                 if_exists: true

    add_index    :contest_winners,
                 :contest_id,
                 name: INDEX_NAME,
                 algorithm: :concurrently
  end
end
