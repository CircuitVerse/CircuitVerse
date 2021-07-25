class AddLisResultSourcedidToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :lis_result_sourced_id, :string
  end
end
