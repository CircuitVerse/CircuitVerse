class AddViewToProject < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :view, :bigint
  end
end
