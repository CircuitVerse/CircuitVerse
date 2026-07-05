# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupMember, type: :model do
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

  describe "subgroup membership" do
    before do
      @subgroup = FactoryBot.create(:group, name: "Team A", parent_group: @group)
      @student = FactoryBot.create(:user)
    end

    it "rejects users who are not members of the parent group" do
      member = described_class.new(group: @subgroup, user: @student)
      expect(member).not_to be_valid
      expect(member.errors[:user]).to be_present
    end

    it "allows members of the parent group" do
      FactoryBot.create(:group_member, group: @group, user: @student)
      expect(described_class.new(group: @subgroup, user: @student)).to be_valid
    end

    it "allows the parent group's primary mentor" do
      expect(described_class.new(group: @subgroup, user: @user)).to be_valid
    end

    it "allows the same user in multiple subgroups of one parent" do
      other_subgroup = FactoryBot.create(:group, name: "Team B", parent_group: @group)
      FactoryBot.create(:group_member, group: @group, user: @student)
      FactoryBot.create(:group_member, group: @subgroup, user: @student)
      expect(described_class.new(group: other_subgroup, user: @student)).to be_valid
    end

    it "does not send a welcome email for subgroup membership" do
      FactoryBot.create(:group_member, group: @group, user: @student)
      expect_any_instance_of(described_class).not_to receive(:send_welcome_email)
      FactoryBot.create(:group_member, group: @subgroup, user: @student)
    end
  end
end
