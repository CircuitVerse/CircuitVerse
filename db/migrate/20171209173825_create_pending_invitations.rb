class CreatePendingInvitations < ActiveRecord::Migration[5.1]
  def change
    create_table :pending_invitations do |t|
      t.references :group, foreign_key: true
      t.string :email

      t.timestamps
    end
  end
end
