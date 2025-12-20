# frozen_string_literal: true

class AddIndexesToUsersSearchColumns < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    # Add index on LOWER(country) for case-insensitive equality searches
    execute <<-SQL.squish
      CREATE INDEX CONCURRENTLY IF NOT EXISTS index_users_on_lower_country
      ON users (LOWER(country))
    SQL

    # Enable pg_trgm extension if not already enabled (for ILIKE searches)
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm"

    # Add GIN index on educational_institute for ILIKE pattern matching
    execute <<-SQL.squish
      CREATE INDEX CONCURRENTLY IF NOT EXISTS index_users_on_educational_institute_trgm
      ON users USING gin (educational_institute gin_trgm_ops)
    SQL
  end

  def down
    execute "DROP INDEX CONCURRENTLY IF EXISTS index_users_on_lower_country"
    execute "DROP INDEX CONCURRENTLY IF EXISTS index_users_on_educational_institute_trgm"
  end
end
