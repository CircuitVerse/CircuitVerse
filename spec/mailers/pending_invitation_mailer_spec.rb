# frozen_string_literal: true

require "rails_helper"

RSpec.describe PendingInvitationMailer, type: :mailer do
  before do
    @group = FactoryBot.create(:group, mentor: FactoryBot.create(:user), name: "Test group")
    @pending_invitation = FactoryBot.create(:pending_invitation, group: @group)
  end

  describe "#new_pending_email" do
    let(:mail) { PendingInvitationMailer.new_pending_email(@pending_invitation) }

    it "sends new assignment mail" do
      expect(mail.to).to eq([@pending_invitation.email])
      expect(mail.subject).to eq("Added to a group in CircuitVerse ")
    end
  end
end
