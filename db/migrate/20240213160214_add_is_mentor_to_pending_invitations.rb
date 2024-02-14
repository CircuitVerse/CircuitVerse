class AddIsMentorToPendingInvitations < ActiveRecord::Migration[7.0]
  def change
    add_column :pending_invitations, :isMentor, :boolean, default: false
  end
end
