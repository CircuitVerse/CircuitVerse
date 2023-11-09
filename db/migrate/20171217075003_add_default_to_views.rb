class AddDefaultToViews < ActiveRecord::Migration[5.1]
  def change
    change_column_default :projects, :view, 1
  end
end
