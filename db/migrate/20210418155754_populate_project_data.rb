class PopulateProjectData < ActiveRecord::Migration[6.0]
  def up
  ActiveRecord::Base.connection.execute <<~SQL
      INSERT INTO project_data (project_id, data, created_at, updated_at)
      SELECT id, data, created_at, updated_at
      FROM projects
    SQL
  end
end
