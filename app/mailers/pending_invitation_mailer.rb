# frozen_string_literal: true

class PendingInvitationMailer < ApplicationMailer
  def new_pending_email(pending_invitation)
    @group = pending_invitation.group
    @organization = pending_invitation.organization
    @email = pending_invitation.email
    subject = @organization ? "Added to an organization in CircuitVerse" : "Added to a group in CircuitVerse"
    mail(to: [@email], subject: subject)
  end
end
