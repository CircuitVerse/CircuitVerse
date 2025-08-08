class AddStarsCountToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :stars_count, :integer, default: 0, null: false
  end
end
