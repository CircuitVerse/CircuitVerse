# frozen_string_literal: true

class AddTagNameConstraint < ActiveRecord::Migration[7.1]
  def up
    # Add a check constraint to prevent empty tag names at the database level
    execute <<-SQL
      ALTER TABLE tags
      ADD CONSTRAINT tags_name_not_empty
      CHECK (name IS NOT NULL AND TRIM(name) <> '')
    SQL

    # Add a unique constraint on tag names to prevent duplicates
    add_index :tags, :name, unique: true, if_not_exists: true
  end

  def down
    execute <<-SQL
      ALTER TABLE tags
      DROP CONSTRAINT IF EXISTS tags_name_not_empty
    SQL

    remove_index :tags, :name, if_exists: true
  end
end
