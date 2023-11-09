# frozen_string_literal: true

class PendingInvitationMailerPreview < ActionMailer::Preview
  def new_pending_email
    PendingInvitationMailer.new_pending_email(PendingInvitation.first)
  end
end
