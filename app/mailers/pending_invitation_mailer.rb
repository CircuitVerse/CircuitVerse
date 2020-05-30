# frozen_string_literal: true

class PendingInvitationMailer < ApplicationMailer
  def new_pending_email(pending_invitation)
    @group = pending_invitation.group # Group.find_by(id:pending_invitation.group_id)
    @email = pending_invitation.email
    mail(to: @email, subject: "Added to a group in CircuitVerse ")
  end
end
