# frozen_string_literal: true

class PendingInvitation < ApplicationRecord
  belongs_to :group
  validates :email, uniqueness: { scope: :group_id, case_sensitive: false }
  after_commit :send_pending_invitation_mail, on: :create

  def send_pending_invitation_mail
    PendingInvitationMailer.new_pending_email(self).deliver_later
  end
end
