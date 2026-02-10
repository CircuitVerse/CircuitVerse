# frozen_string_literal: true

class AddSearchPerformanceIndexes < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def up
    add_index :projects, :view,
              algorithm: :concurrently, if_not_exists: true
    add_index :projects, :stars_count,
              algorithm: :concurrently, if_not_exists: true
    add_index :projects, :created_at,
              algorithm: :concurrently, if_not_exists: true

    add_index :users, :projects_count,
              algorithm: :concurrently, if_not_exists: true
    add_index :users, :created_at,
              algorithm: :concurrently, if_not_exists: true

    add_index :users, "LOWER(country)",
              name: "index_users_on_lower_country",
              algorithm: :concurrently,
              if_not_exists: true

    enable_extension "pg_trgm"

    add_index :users, :educational_institute,
              using: :gin,
              opclass: :gin_trgm_ops,
              algorithm: :concurrently,
              if_not_exists: true
  end

  def down
    remove_index :users, :educational_institute, if_exists: true
    remove_index :users, name: "index_users_on_lower_country", if_exists: true
    remove_index :users, :created_at, if_exists: true
    remove_index :users, :projects_count, if_exists: true
    remove_index :projects, :created_at, if_exists: true
    remove_index :projects, :stars_count, if_exists: true
    remove_index :projects, :view, if_exists: true
  end
end
