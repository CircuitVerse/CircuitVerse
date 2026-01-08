# frozen_string_literal: true

class CleanUpInvalidTags < ActiveRecord::Migration[7.1]
  def up
    # Remove tags with empty or whitespace-only names
    Tag.where("name IS NULL OR name = '' OR TRIM(name) = ''").destroy_all

    # Fix tags with invalid UTF-8 sequences
    Tag.find_each do |tag|
      next unless tag.name.present?

      # Check if the name has invalid encoding
      unless tag.name.valid_encoding?
        # Try to clean the name
        clean_name = tag.name.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
                             .strip
                             .gsub(/\u0000/, "")

        if clean_name.present?
          # Update without validations to avoid issues
          tag.update_column(:name, clean_name)
        else
          # If cleaning results in empty string, delete the tag
          tag.destroy
        end
      end
    end

    # Remove orphaned taggings (where tag was deleted)
    execute <<-SQL
      DELETE FROM taggings
      WHERE tag_id NOT IN (SELECT id FROM tags)
    SQL

    # Remove duplicate taggings (same project and tag)
    execute <<-SQL
      DELETE FROM taggings a USING (
        SELECT MIN(id) as id, project_id, tag_id
        FROM taggings
        GROUP BY project_id, tag_id
        HAVING COUNT(*) > 1
      ) b
      WHERE a.project_id = b.project_id
        AND a.tag_id = b.tag_id
        AND a.id <> b.id
    SQL
  end

  def down
    # This migration cannot be reversed as it destroys data
    raise ActiveRecord::IrreversibleMigration
  end
end
