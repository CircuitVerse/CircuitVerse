class RemoveDataFromProjects < ActiveRecord::Migration[6.0]
  def change
    safety_assured { remove_column :projects, :data, :text }
  end
end
