# frozen_string_literal: true

class AddTagNameConstraint < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      # Add a check constraint to prevent empty tag names at the database level
      execute <<~SQL.squish
        ALTER TABLE tags
        ADD CONSTRAINT tags_name_not_empty
        CHECK (name IS NOT NULL AND TRIM(name) <> '')
      SQL
    end

    # Add a unique index concurrently to avoid blocking writes
    add_index :tags,
              :name,
              unique: true,
              if_not_exists: true,
              algorithm: :concurrently
  end

  def down
    safety_assured do
      execute <<~SQL.squish
        ALTER TABLE tags
        DROP CONSTRAINT IF EXISTS tags_name_not_empty
      SQL
    end

    remove_index :tags,
                 :name,
                 if_exists: true,
                 algorithm: :concurrently
  end
end
