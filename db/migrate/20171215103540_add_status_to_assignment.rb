class AddStatusToAssignment < ActiveRecord::Migration[5.1]
  def change
    add_column :assignments, :status, :string
  end
end
