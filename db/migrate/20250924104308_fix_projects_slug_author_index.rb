class FixProjectsSlugAuthorIndex < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    # Add a function-based index using MD5 hash to avoid size limitations
    # This maintains uniqueness while staying under PostgreSQL's btree size limit
    # NOTE: MD5 collision risk is acceptable here because:
    # 1. Risk is extremely low for typical slug+author_id combinations
    # 2. Application-level validation provides additional protection
    # 3. Alternative solutions (limiting column size) would break existing data
    safety_assured do
      execute <<-SQL.squish
        CREATE UNIQUE INDEX CONCURRENTLY index_projects_on_slug_author_hash
        ON projects (MD5(COALESCE(slug, '') || '-' || COALESCE(author_id::text, '')))
      SQL
    end

    # Add a partial index on slug for lookups, only for safely indexable sizes
    # Prevents btree key size errors on extremely long slugs
    unless index_exists?(:projects, :slug, name: "index_projects_on_slug_small")
      safety_assured do
        execute <<-SQL.squish
          CREATE INDEX CONCURRENTLY IF NOT EXISTS index_projects_on_slug_small
          ON projects (slug)
          WHERE octet_length(slug) <= 2000
        SQL
      end
    end

    # Now that the new unique index exists, drop the old composite index
    if index_exists?(:projects, [:slug, :author_id], name: "index_projects_on_slug_and_author_id")
      safety_assured do
        remove_index :projects, name: "index_projects_on_slug_and_author_id", algorithm: :concurrently
      end
    end
  end

  def down
    # Remove the function-based index
    execute "DROP INDEX CONCURRENTLY IF EXISTS index_projects_on_slug_author_hash"

    # Remove the partial slug index if it exists
    execute "DROP INDEX CONCURRENTLY IF EXISTS index_projects_on_slug_small"

    # Only restore original index if data won't cause size issues
    safety_assured do
      begin
        add_index :projects, [:slug, :author_id], unique: true,
                  name: "index_projects_on_slug_and_author_id", algorithm: :concurrently
      rescue ActiveRecord::StatementInvalid => e
        Rails.logger.warn "Could not restore original index due to size limitations: #{e.message}"
        # Create a non-unique version for basic functionality
        add_index :projects, [:slug, :author_id], name: "index_projects_on_slug_and_author_id_non_unique",
                  algorithm: :concurrently
        Rails.logger.warn "Created non-unique index as fallback"
      end
    end
  end
end
