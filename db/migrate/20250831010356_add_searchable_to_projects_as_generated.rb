class AddSearchableToProjectsAsGenerated < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    remove_index :projects, :searchable, if_exists: true

    safety_assured { remove_column :projects, :searchable, if_exists: true }

    safety_assured do
      add_column :projects, :searchable, :virtual, stored: true, type: :tsvector, as: <<~SQL
          setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
          setweight(to_tsvector('english', coalesce(description,'')), 'B')
      SQL
    end

    add_index :projects, :searchable, using: :gin, algorithm: :concurrently
  end
end
