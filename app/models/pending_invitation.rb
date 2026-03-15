# frozen_string_literal: true

# Represents a pending group invitation for a user who hasn't signed up yet.
# Ensures uniqueness of email per group at the model level.
class PendingInvitation < ApplicationRecord
  belongs_to :group
  validates :email, uniqueness: { scope: :group_id }
  after_commit :send_pending_invitation_mail, on: :create

  # Enqueues an invitation email to the pending user.
  def send_pending_invitation_mail
    PendingInvitationMailer.new_pending_email(self).deliver_later
  end
end
