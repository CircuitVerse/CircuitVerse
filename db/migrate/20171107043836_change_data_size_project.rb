class ChangeDataSizeProject < ActiveRecord::Migration[5.1]
  def change
    change_column :projects, :data, :text, :limit => 16777215
  end
end
