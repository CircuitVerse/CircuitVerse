# frozen_string_literal: true

require "rails_helper"

RSpec.describe Group, type: :model do
  before do
    @mentor = FactoryBot.create(:user)
  end

  describe "associations" do
    it { is_expected.to belong_to(:mentor) }
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:group_members) }
    it { is_expected.to have_many(:assignments) }
    it { is_expected.to have_many(:pending_invitations) }
  end

  describe "callbacks" do
    it "calls respective callbacks" do
      expect_any_instance_of(described_class).to receive(:send_creation_mail)
      FactoryBot.create(:group, mentor: @mentor)
    end
  end

  describe "public methods" do
    it "sends group creation mail" do
      group = FactoryBot.create(:group, mentor: @mentor)
      expect do
        group.send_creation_mail
      end.to have_enqueued_job.on_queue("mailers")
    end

    it "reset the group_token and update expiration date" do
      group = FactoryBot.create(:group, mentor: @mentor)
      expect do
        group.reset_group_token
      end.to change(group, :group_token)
        .and change(group, :token_expires_at)
    end
  end
end
