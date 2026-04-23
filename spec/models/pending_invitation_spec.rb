# frozen_string_literal: true

require "rails_helper"

RSpec.describe PendingInvitation, type: :model do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
  end

  describe "associations" do
    it { is_expected.to belong_to(:group) }
  end

  describe "validations" do
    it "is invalid with a duplicate email in the same group" do
      FactoryBot.create(:pending_invitation, group: @group, email: "test@example.com")
      duplicate = FactoryBot.build(:pending_invitation, group: @group, email: "test@example.com")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include("has already been taken")
    end

    it "is valid with the same email in a different group" do
      other_group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
      FactoryBot.create(:pending_invitation, group: @group, email: "test@example.com")
      invitation = FactoryBot.build(:pending_invitation, group: other_group, email: "test@example.com")
      expect(invitation).to be_valid
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
