# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupMember, type: :model do
  include ActiveJob::TestHelper

  before do
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @user)
  end

  describe "associations" do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:user) }
  end

  describe "callbacks" do
    it "calls respective callbacks" do
      expect_any_instance_of(described_class).to receive(:send_welcome_email)
      FactoryBot.create(:group_member, user: @user, group: @group)
    end
  end

  describe "public methods" do
    it "sends welcome email with scalar IDs" do
      group_member = FactoryBot.create(:group_member, user: @user, group: @group)
      expect do
        group_member.send_welcome_email
      end.to have_enqueued_job(ActionMailer::MailDeliveryJob)
        .with("GroupMailer", "new_member_email", "deliver_now", { args: [@user.id, @group.id] })
        .on_queue("mailers")
    end

    it "executes enqueued welcome email safely even if member is deleted before processing" do
      group_member = FactoryBot.create(:group_member, user: @user, group: @group)
      group_member.send_welcome_email
      group_member.destroy!

      expect { perform_enqueued_jobs }.not_to raise_error
    end
  end
end
