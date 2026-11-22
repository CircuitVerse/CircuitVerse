# frozen_string_literal: true

require "rails_helper"

RSpec.describe PendingInvitation, type: :model do
  include ActiveJob::TestHelper

  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
  end

  describe "associations" do
    it { is_expected.to belong_to(:group).optional }
    it { is_expected.to belong_to(:organization).optional }
  end

  describe "callbacks" do
    it "alls respective callbacks" do
      expect_any_instance_of(described_class).to receive(:send_pending_invitation_mail)
      FactoryBot.create(:pending_invitation, group: @group)
    end
  end

  describe "public methods" do
    it "sends pending invitation mail with scalar ID" do
      invitation = FactoryBot.create(:pending_invitation, group: @group)
      expect do
        invitation.send_pending_invitation_mail
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob)
        .with("PendingInvitationMailer", "new_pending_email", "deliver_now", { args: [invitation.id] })
        .on_queue("mailers")
    end

    it "executes enqueued pending invitation mail safely even if invitation is deleted before processing" do
      invitation = FactoryBot.create(:pending_invitation, group: @group)
      invitation.send_pending_invitation_mail
      invitation.destroy!

      expect { perform_enqueued_jobs }.not_to raise_error
    end
  end
end
