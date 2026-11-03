# frozen_string_literal: true

require "rails_helper"

RSpec.describe Group, type: :model do
  before do
    @primary_mentor = FactoryBot.create(:user)
  end

  describe "associations" do
    it { is_expected.to belong_to(:primary_mentor) }
    it { is_expected.to belong_to(:parent_group).optional }
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:group_members) }
    it { is_expected.to have_many(:assignments) }
    it { is_expected.to have_many(:pending_invitations) }

    it {
      expect(subject).to have_many(:subgroups)
        .class_name("Group").with_foreign_key(:parent_group_id).dependent(:destroy)
    }
  end

  describe "callbacks" do
    it "calls respective callbacks" do
      expect_any_instance_of(described_class).to receive(:send_creation_mail)
      FactoryBot.create(:group, primary_mentor: @primary_mentor)
    end
  end

  describe "public methods" do
    it "sends group creation mail" do
      group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
      expect do
        group.send_creation_mail
      end.to have_enqueued_job.on_queue("mailers")
    end

    it "reset the group_token and update expiration date" do
      group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
      expect do
        group.reset_group_token
      end.to change(group, :group_token)
        .and change(group, :token_expires_at)
    end
  end

  describe "subgroups" do
    before do
      @parent = FactoryBot.create(:group, primary_mentor: @primary_mentor)
    end

    it "inherits the parent's primary mentor and is marked as a subgroup" do
      subgroup = described_class.create!(name: "Team A", parent_group: @parent)
      expect(subgroup).to be_subgroup
      expect(subgroup.primary_mentor).to eq(@primary_mentor)
    end

    it "overrides a supplied primary mentor with the parent's" do
      other_mentor = FactoryBot.create(:user)
      subgroup = described_class.create!(name: "Team A", parent_group: @parent, primary_mentor: other_mentor)
      expect(subgroup.primary_mentor).to eq(@primary_mentor)
    end

    it "rejects a subgroup of a subgroup" do
      subgroup = described_class.create!(name: "Team A", parent_group: @parent)
      grandchild = described_class.new(name: "Team A-1", parent_group: subgroup)

      expect(grandchild).not_to be_valid
      expect(grandchild.errors[:parent_group]).to be_present
    end

    it "rejects two subgroups with the same name under one parent" do
      described_class.create!(name: "Team A", parent_group: @parent)
      duplicate = described_class.new(name: "team a", parent_group: @parent)

      expect(duplicate).not_to be_valid
    end

    it "allows the same subgroup name under a different parent" do
      other_parent = FactoryBot.create(:group, primary_mentor: @primary_mentor)
      described_class.create!(name: "Team A", parent_group: @parent)

      expect(described_class.new(name: "Team A", parent_group: other_parent)).to be_valid
    end

    it "does not send a creation mail for a subgroup" do
      expect_any_instance_of(described_class).not_to receive(:send_creation_mail)
      described_class.create!(name: "Team A", parent_group: @parent)
    end

    it "excludes subgroups from the top_level scope" do
      subgroup = described_class.create!(name: "Team A", parent_group: @parent)
      expect(described_class.top_level).to include(@parent)
      expect(described_class.top_level).not_to include(subgroup)
    end
  end
end
