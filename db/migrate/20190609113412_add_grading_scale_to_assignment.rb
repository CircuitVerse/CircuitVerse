class AddGradingScaleToAssignment < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :grading_scale, :integer, default: 0
    add_column :assignments, :grades_finalized, :boolean, default: false
  end
end
