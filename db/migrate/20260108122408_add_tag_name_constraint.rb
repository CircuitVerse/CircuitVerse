# frozen_string_literal: true

class AddTagNameConstraint < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      # Add a check constraint to prevent empty tag names at the database level
      # Add it as NOT VALID so adding the constraint does not require a full table
      # scan/validation up front (avoids long blocking locks). Validate the
      # constraint in a follow-up migration or background step using
      # `ALTER TABLE tags VALIDATE CONSTRAINT tags_name_not_empty`.
      execute <<~SQL.squish
        ALTER TABLE tags
        ADD CONSTRAINT tags_name_not_empty
        CHECK (name IS NOT NULL AND TRIM(name) <> '') NOT VALID
      SQL
    end

    # NOTE: Do not add a case-sensitive unique index here. A separate migration
    # will create a case-insensitive unique index on LOWER(name) to match the
    # model-level case-insensitive validation.
  end

  def down
    safety_assured do
      execute <<~SQL.squish
        ALTER TABLE tags
        DROP CONSTRAINT IF EXISTS tags_name_not_empty
      SQL
    end
  end
end
