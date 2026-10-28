# frozen_string_literal: true

require "rails_helper"

RSpec.describe PendingInvitationMailer, type: :mailer do
  before do
    @group = FactoryBot.create(:group, primary_mentor: FactoryBot.create(:user), name: "Test group")
    @pending_invitation = FactoryBot.create(:pending_invitation, group: @group)
  end

  describe "#new_pending_email" do
    let(:mail) { described_class.new_pending_email(@pending_invitation) }

    it "sends new assignment mail" do
      expect(mail.to).to eq([@pending_invitation.email])
      expect(mail.subject).to eq("Added to a group in CircuitVerse ")
    end

    it "supports scalar ID as argument" do
      mail_from_id = described_class.new_pending_email(@pending_invitation.id)
      expect(mail_from_id.to).to eq([@pending_invitation.email])
      expect(mail_from_id.subject).to eq("Added to a group in CircuitVerse ")
    end

    it "handles missing/deleted records gracefully" do
      expect(described_class.new_pending_email(999_999).message).to be_a(ActionMailer::Base::NullMail)
    end
  end
end
