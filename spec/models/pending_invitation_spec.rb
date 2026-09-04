# frozen_string_literal: true

require "rails_helper"

RSpec.describe PendingInvitation, type: :model do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
    @organization = FactoryBot.create(:organization)
  end

  describe "associations" do
    it { is_expected.to belong_to(:group).optional }
    it { is_expected.to belong_to(:organization).optional }
  end

  describe "validations" do
    it "is valid with a group" do
      invitation = described_class.new(group: @group, email: "user@example.com")
      expect(invitation).to be_valid
    end

    it "is valid with an organization" do
      invitation = described_class.new(organization: @organization, email: "user@example.com")
      expect(invitation).to be_valid
    end

    it "is invalid with neither a group nor an organization" do
      invitation = described_class.new(email: "user@example.com")
      expect(invitation).not_to be_valid
    end
  end

  describe "callbacks" do
    it "calls respective callbacks" do
      expect_any_instance_of(described_class).to receive(:send_pending_invitation_mail)
      FactoryBot.create(:pending_invitation, group: @group)
    end
  end

  describe "public methods" do
    it "sends pending invitation mail" do
      invitation = FactoryBot.create(:pending_invitation, group: @group)
      expect do
        invitation.send_pending_invitation_mail
      end.to have_enqueued_job.on_queue("mailers")
    end
  end
end
