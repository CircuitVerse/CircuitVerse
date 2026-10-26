# frozen_string_literal: true

require "rails_helper"

RSpec.describe PendingInvitation, type: :model do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
  end

  describe "associations" do
    it { is_expected.to belong_to(:group).optional }
    it { is_expected.to belong_to(:organization).optional }
  end

  describe "validations" do
    it "accepts a single valid email address" do
      invitation = FactoryBot.build(:pending_invitation, group: @group, email: "first.last+tag@sub.example.org")

      expect(invitation).to be_valid
    end

    it "rejects a comma-separated list of addresses" do
      invitation = FactoryBot.build(:pending_invitation, group: @group, email: "a@x.com,b@y.com,c@z.com")

      expect(invitation).not_to be_valid
      expect(invitation.errors[:email]).to be_present
    end

    it "rejects commas before the @ sign, which Mail would split into several recipients" do
      invitation = FactoryBot.build(:pending_invitation, group: @group, email: "a,b,c@x.com")

      expect(invitation).not_to be_valid
    end
  end

  describe "callbacks" do
    it "alls respective callbacks" do
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
