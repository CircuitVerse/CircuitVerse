class DefaultAccessTypeProject < ActiveRecord::Migration[5.1]
  def change
    change_column_default :projects, :project_access_type, "Public"
  end
end
