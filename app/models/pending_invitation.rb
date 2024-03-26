# frozen_string_literal: true

#
# == Schema Information
#
# Table name: pending_invitations
#
#  id         :bigint           not null, primary key
#  group_id   :bigint
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_pending_invitations_on_group_id  (group_id)
#  index_pending_invitations_on_group_id_and_email  (group_id,email) UNIQUE
#

class PendingInvitation < ApplicationRecord
  belongs_to :group
  after_commit :send_pending_invitation_mail, on: :create

  # @return [void]
  def send_pending_invitation_mail
    PendingInvitationMailer.new_pending_email(self).deliver_later
  end
end
