# frozen_string_literal: true

class AddUniqueIndexesForHasOneAssociations < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    remove_index :featured_circuits, :project_id, algorithm: :concurrently
    add_index :featured_circuits, :project_id, unique: true, algorithm: :concurrently

    remove_index :grades, :project_id, algorithm: :concurrently
    add_index :grades, :project_id, unique: true, algorithm: :concurrently

    remove_index :contest_winners, :project_id, algorithm: :concurrently
    add_index :contest_winners, :project_id, unique: true, algorithm: :concurrently

    remove_index :contest_winners, :submission_id, algorithm: :concurrently
    add_index :contest_winners, :submission_id, unique: true, algorithm: :concurrently
  end
end
