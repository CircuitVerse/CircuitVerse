class RemoveTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :assignment_submissions
  end
end
