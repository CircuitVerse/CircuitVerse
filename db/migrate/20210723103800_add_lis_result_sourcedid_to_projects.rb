class AddLisResultSourcedidToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :lis_result_sourcedid, :string
  end
end
