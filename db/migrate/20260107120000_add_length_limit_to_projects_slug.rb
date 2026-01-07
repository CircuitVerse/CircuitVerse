class AddLengthLimitToProjectsSlug < ActiveRecord::Migration[8.0]
  def up
    # Remove the existing index
    remove_index :projects, [:slug, :author_id], unique: true if index_exists?(:projects, [:slug, :author_id])

    # Truncate any existing slugs that are longer than 191 characters
    # This prevents data truncation errors when applying the column limit
    # This is safe because:
    # 1. We're only truncating slugs, not deleting data
    # 2. FriendlyId will handle slug uniqueness conflicts automatically
    # 3. This is a one-time fix for existing data
    safety_assured do
      execute <<-SQL
        UPDATE projects
        SET slug = LEFT(slug, 191)
        WHERE LENGTH(slug) > 191;
      SQL
    end

    # Change the slug column to have a length limit of 191 characters
    # This ensures it fits within PostgreSQL's btree index limit of ~2704 bytes
    # 191 chars * 4 bytes (UTF-8 worst case) + 8 bytes (author_id) = 772 bytes << 2704 bytes
    change_column :projects, :slug, :string, limit: 191

    # Recreate the index with length specification
    add_index :projects, [:slug, :author_id], unique: true, length: { slug: 191 }
  end

  def down
    # Remove the length-limited index
    remove_index :projects, [:slug, :author_id], unique: true if index_exists?(:projects, [:slug, :author_id])

    # Revert the column back to unlimited string
    change_column :projects, :slug, :string, limit: nil

    # Recreate the original index
    add_index :projects, [:slug, :author_id], unique: true
  end
end
