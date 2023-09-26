# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupMember do
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
    it "sends welcome email" do
      group_member = FactoryBot.create(:group_member, user: @user, group: @group)
      expect do
        group_member.send_welcome_email
      end.to have_enqueued_job.on_queue("mailers")
    end
  end
end
