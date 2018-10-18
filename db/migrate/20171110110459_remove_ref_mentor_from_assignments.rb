class RemoveRefMentorFromAssignments < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :assignments, column: :mentor_id
    remove_reference :assignments, :mentor
  end
end
