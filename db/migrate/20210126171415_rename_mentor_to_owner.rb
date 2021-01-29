class RenameMentorToOwner < ActiveRecord::Migration[6.0]
  def change
  	rename_column :groups, :mentor_id, :owner_id
  end
end
