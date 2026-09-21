# frozen_string_literal: true

require "rails_helper"

RSpec.describe PendingInvitationMailer, type: :mailer do
  describe "#new_pending_email" do
    context "for a group invitation" do
      before do
        @group = FactoryBot.create(:group, primary_mentor: FactoryBot.create(:user), name: "Test group")
        @pending_invitation = FactoryBot.create(:pending_invitation, group: @group)
      end

      let(:mail) { described_class.new_pending_email(@pending_invitation) }

      it "sends the group invitation mail" do
        expect(mail.to).to eq([@pending_invitation.email])
        expect(mail.subject).to eq("Added to a group in CircuitVerse")
        expect(mail.body.encoded).to include("Test group")
      end
    end

    context "for an organization invitation" do
      before do
        @organization = FactoryBot.create(:organization, name: "Test Org")
        @pending_invitation = PendingInvitation.new(organization: @organization, email: "invitee@example.com")
      end

      let(:mail) { described_class.new_pending_email(@pending_invitation) }

      it "sends the organization invitation mail" do
        expect(mail.to).to eq(["invitee@example.com"])
        expect(mail.subject).to eq("Added to an organization in CircuitVerse")
        expect(mail.body.encoded).to include("Test Org")
      end
    end
  end
end
