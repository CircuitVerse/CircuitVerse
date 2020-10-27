class AddSearchableColumnToProjects < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      ALTER TABLE projects
      ADD COLUMN searchable tsvector GENERATED ALWAYS AS (
        setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
        setweight(to_tsvector('english', coalesce(description,'')), 'B')
      ) STORED;
    SQL
  end

  def down
    remove_column :projects, :searchable
  end
end
