class RenameMentorToPrimaryMentor < ActiveRecord::Migration[6.0]
  def change
  	rename_column :groups, :mentor_id, :primary_mentor_id
  end
end
