class AddMentorToPendingInvitations < ActiveRecord::Migration[7.0]
  def change
    add_column :pending_invitations, :mentor, :boolean, default: true
    
    # Set all existing records to have mentor as true
    PendingInvitation.update_all(mentor: true)
  end
end