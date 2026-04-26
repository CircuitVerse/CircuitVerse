# frozen_string_literal: true

require "rails_helper"

RSpec.describe Group, type: :model do
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

    describe "#can_join?" do
      context "when allowed_domain is blank" do
        it "allows any email to join" do
          group = FactoryBot.create(:group, primary_mentor: @primary_mentor, allowed_domain: nil)
          expect(group.can_join?("user@example.com")).to be true
          expect(group.can_join?("user@sjec.ac.in")).to be true
        end
      end

      context "when allowed_domain is set" do
        it "allows users with matching domain to join" do
          group = FactoryBot.create(:group, primary_mentor: @primary_mentor, allowed_domain: "sjec.ac.in")
          expect(group.can_join?("user@sjec.ac.in")).to be true
          expect(group.can_join?("student@sjec.ac.in")).to be true
        end

        it "rejects users with different domain" do
          group = FactoryBot.create(:group, primary_mentor: @primary_mentor, allowed_domain: "sjec.ac.in")
          expect(group.can_join?("user@example.com")).to be false
          expect(group.can_join?("user@gmail.com")).to be false
        end

        it "is case-insensitive" do
          group = FactoryBot.create(:group, primary_mentor: @primary_mentor, allowed_domain: "sjec.ac.in")
          expect(group.can_join?("user@SJEC.AC.IN")).to be true
          expect(group.can_join?("user@Sjec.ac.in")).to be true
        end
      end
    end
  end

  describe "validations" do
    it "validates allowed_domain format correctly" do
      group = FactoryBot.build(:group, primary_mentor: @primary_mentor, allowed_domain: "sjec.ac.in")
      expect(group).to be_valid
    end

    it "normalizes allowed_domain before validation" do
      group = FactoryBot.build(:group, primary_mentor: @primary_mentor, allowed_domain: "  SJEC.AC.IN  ")

      group.validate

      expect(group.allowed_domain).to eq("sjec.ac.in")
    end

    it "rejects invalid domain formats" do
      group = FactoryBot.build(:group, primary_mentor: @primary_mentor, allowed_domain: "invalid")
      expect(group).not_to be_valid
      expect(group.errors[:allowed_domain]).to include("must be a valid domain (e.g., example.com)")
    end

    it "allows blank allowed_domain" do
      group = FactoryBot.build(:group, primary_mentor: @primary_mentor, allowed_domain: nil)
      expect(group).to be_valid
    end

    it "rejects domain without TLD" do
      group = FactoryBot.build(:group, primary_mentor: @primary_mentor, allowed_domain: "example")
      expect(group).not_to be_valid
    end
  end
end
