# frozen_string_literal: true

class AddUniqueIndexesToGoogleClassroomId < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    # Add unique index to assignments.google_classroom_id
    add_index :assignments, :google_classroom_id, unique: true, 
              where: "google_classroom_id IS NOT NULL",
              name: "index_assignments_on_google_classroom_id_unique",
              algorithm: :concurrently
    
    # Add unique index to groups.google_classroom_id
    add_index :groups, :google_classroom_id, unique: true,
              where: "google_classroom_id IS NOT NULL",
              name: "index_groups_on_google_classroom_id_unique",
              algorithm: :concurrently
  end
end
