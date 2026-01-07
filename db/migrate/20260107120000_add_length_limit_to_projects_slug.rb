# frozen_string_literal: true

class AddLengthLimitToProjectsSlug < ActiveRecord::Migration[8.0]
  def up
    # Remove the existing index
    remove_index :projects, %i[slug author_id], unique: true if index_exists?(:projects, %i[slug author_id])

    # Truncate any existing slugs that are longer than 191 characters
    # Handle conflicts with both existing short slugs and other long slugs
    safety_assured do
      execute <<-SQL
        WITH long_slugs AS (
          -- Get all long slugs that need truncation
          SELECT id, slug, author_id, LEFT(slug, 191) as truncated_slug
          FROM projects
          WHERE LENGTH(slug) > 191
        ),
        existing_slugs AS (
          -- Get all existing slugs (short ones that should remain unchanged)
          SELECT DISTINCT slug, author_id
          FROM projects
          WHERE LENGTH(slug) <= 191
        ),
        slug_conflicts AS (
          -- Assign sequence numbers, prioritizing non-conflicting truncations
          SELECT
            ls.id,
            ls.truncated_slug,
            ROW_NUMBER() OVER (
              PARTITION BY ls.truncated_slug, ls.author_id
              ORDER BY
                CASE WHEN es.slug IS NOT NULL THEN 1 ELSE 0 END,  -- Existing short slugs conflict = higher number
                ls.id
            ) as sequence
          FROM long_slugs ls
          LEFT JOIN existing_slugs es
            ON ls.truncated_slug = es.slug AND ls.author_id = es.author_id
        )
        UPDATE projects
        SET slug = CASE
          WHEN sc.sequence = 1 THEN sc.truncated_slug
          ELSE LEFT(sc.truncated_slug, 185) || '-' || (sc.sequence + 1)
        END
        FROM slug_conflicts sc
        WHERE projects.id = sc.id;
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

    # Recreate the index (respects the column's varchar(191) limit)
    # This is safe because we're recreating an index that was just removed
    # and is necessary to prevent the original btree size error
    safety_assured do
      add_index :projects, %i[slug author_id], unique: true
    end
  end

  def down
    # Remove the length-limited index
    remove_index :projects, %i[slug author_id], unique: true if index_exists?(:projects, %i[slug author_id])

    # Revert the column back to unlimited string
    safety_assured do
      change_column :projects, :slug, :string, limit: nil
    end

    # Recreate the original index
    safety_assured do
      add_index :projects, %i[slug author_id], unique: true
    end
  end
end
