# frozen_string_literal: true

class PendingInvitation < ApplicationRecord
  belongs_to :group, optional: true
  belongs_to :organization, optional: true

  validate :group_or_organization_present

  after_commit :send_pending_invitation_mail, on: :create

  def send_pending_invitation_mail
    PendingInvitationMailer.new_pending_email(self).deliver_later
  end

  private

    def group_or_organization_present
      return if group_id.present? || organization_id.present?

      errors.add(:base, "must belong to a group or organization")
    end
end
