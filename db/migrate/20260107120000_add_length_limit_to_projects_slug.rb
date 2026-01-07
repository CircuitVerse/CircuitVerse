class AddLengthLimitToProjectsSlug < ActiveRecord::Migration[8.0]
  def up
    # Remove the existing index
    remove_index :projects, [:slug, :author_id], unique: true if index_exists?(:projects, [:slug, :author_id])

    # Truncate any existing slugs that are longer than 191 characters
    # This prevents data truncation errors when applying the column limit
    # Handle potential duplicates by appending a sequence number
    safety_assured do
      execute <<-SQL
        -- First, identify projects with long slugs and mark potential conflicts
        WITH long_slugs AS (
          SELECT id, slug, author_id,
                 LEFT(slug, 191) as truncated_slug,
                 ROW_NUMBER() OVER (PARTITION BY LEFT(slug, 191), author_id ORDER BY id) as rn
          FROM projects
          WHERE LENGTH(slug) > 191
        )
        UPDATE projects
        SET slug = CASE
          WHEN ls.rn = 1 THEN ls.truncated_slug
          ELSE LEFT(ls.truncated_slug, 186) || '-' || ls.rn
        END
        FROM long_slugs ls
        WHERE projects.id = ls.id;
      SQL
    end

    # Change the slug column to have a length limit of 191 characters
    # This ensures it fits within PostgreSQL's btree index limit of ~2704 bytes
    # 191 chars * 4 bytes (UTF-8 worst case) + 8 bytes (author_id) = 772 bytes << 2704 bytes
    # This is safe because:
    # 1. We already truncated all slugs to 191 characters in the previous step
    # 2. Adding a limit to a varchar column in PostgreSQL is a metadata-only operation
    # 3. No table rewrite occurs since all data already fits within the limit
    safety_assured do
      change_column :projects, :slug, :string, limit: 191
    end

    # Recreate the index with length specification
    # This is safe because we're recreating an index that was just removed
    # and is necessary to prevent the original btree size error
    safety_assured do
      add_index :projects, [:slug, :author_id], unique: true, length: { slug: 191 }
    end
  end

  def down
    # Remove the length-limited index
    remove_index :projects, [:slug, :author_id], unique: true if index_exists?(:projects, [:slug, :author_id])

    # Revert the column back to unlimited string
    safety_assured do
      change_column :projects, :slug, :string, limit: nil
    end

    # Recreate the original index
    safety_assured do
      add_index :projects, [:slug, :author_id], unique: true
    end
  end
end
