# frozen_string_literal: true

require "rails_helper"

RSpec.describe Group, type: :model do
  include ActiveJob::TestHelper

  before do
    @primary_mentor = FactoryBot.create(:user)
  end

  describe "associations" do
    it { is_expected.to belong_to(:primary_mentor) }
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:group_members) }
    it { is_expected.to have_many(:assignments) }
    it { is_expected.to have_many(:pending_invitations) }
  end

  describe "callbacks" do
    it "calls respective callbacks" do
      expect_any_instance_of(described_class).to receive(:send_creation_mail)
      FactoryBot.create(:group, primary_mentor: @primary_mentor)
    end
  end

  describe "public methods" do
    it "sends group creation mail with scalar IDs" do
      group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
      expect do
        group.send_creation_mail
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob)
        .with("GroupMailer", "new_group_email", "deliver_now", { args: [@primary_mentor.id, group.id] })
        .on_queue("mailers")
    end

    it "executes enqueued group mail safely even if group is deleted before processing" do
      group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
      group.send_creation_mail
      group.destroy!

      expect { perform_enqueued_jobs }.not_to raise_error
    end

    it "reset the group_token and update expiration date" do
      group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
      expect do
        group.reset_group_token
      end.to change(group, :group_token)
        .and change(group, :token_expires_at)
    end
  end
end
