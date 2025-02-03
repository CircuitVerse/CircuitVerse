class AddRemarksToGrades < ActiveRecord::Migration[5.1]
  def change
    add_column :grades, :remarks, :string
  end
end
