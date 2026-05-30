class AddSearchableToProjectsAsGenerated < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    remove_index :projects, :searchable, if_exists: true, algorithm: :concurrently

    safety_assured do
      # Drop any legacy trigger/function created by hairtrigger/SQL, if present
      execute "DROP TRIGGER IF EXISTS projects_searchable_update ON projects"
      execute "DROP FUNCTION IF EXISTS projects_searchable_tsvector_update()"
      remove_column :projects, :searchable, if_exists: true
    end

    safety_assured do
      add_column :projects, :searchable, :virtual, stored: true, type: :tsvector, as: <<~SQL
          setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
          setweight(to_tsvector('english', coalesce(description,'')), 'B')
      SQL
    end
    add_index :projects, :searchable, using: :gin, algorithm: :concurrently
  end
end
