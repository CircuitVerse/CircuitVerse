class AddSearchPerformanceIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :projects, :view
    add_index :projects, :stars_count
    add_index :projects, :created_at

    add_index :users, :projects_count
    add_index :users, :created_at

    add_index :users, "LOWER(country)", name: "index_users_on_lower_country"

    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")
    add_index :users, :educational_institute,
              using: :gin,
              opclass: :gin_trgm_ops
  end
end