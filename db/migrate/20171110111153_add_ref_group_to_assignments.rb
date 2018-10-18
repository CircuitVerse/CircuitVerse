class AddRefGroupToAssignments < ActiveRecord::Migration[5.1]
  def change
    add_reference :assignments, :group, foreign_key: true
  end
end
