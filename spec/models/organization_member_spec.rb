# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizationMember, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject { FactoryBot.build(:organization_member) }

    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:organization_id) }
  end

  describe "enum roles" do
    it "defines the correct roles" do
      expect(described_class.roles).to eq({ "admin" => 0, "mentor" => 1, "member" => 2 })
    end

    it "can be set to admin" do
      member = FactoryBot.build(:organization_member, role: :admin)
      expect(member).to be_admin
    end

    it "can be set to mentor" do
      member = FactoryBot.build(:organization_member, role: :mentor)
      expect(member).to be_mentor
    end

    it "can be set to member" do
      member = FactoryBot.build(:organization_member, role: :member)
      expect(member).to be_member
    end

    it "raises an error when given an invalid role" do
      expect do
        FactoryBot.build(:organization_member, role: :superuser)
      end.to raise_error(ArgumentError)
    end
  end

  describe "uniqueness per organization" do
    it "does not allow the same user to join the same organization twice" do
      org = FactoryBot.create(:organization)
      user = FactoryBot.create(:user)
      FactoryBot.create(:organization_member, organization: org, user: user)

      duplicate = FactoryBot.build(:organization_member, organization: org, user: user)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include("has already been taken")
    end

    it "allows the same user to be a member of different organizations" do
      user = FactoryBot.create(:user)
      org1 = FactoryBot.create(:organization)
      org2 = FactoryBot.create(:organization)

      FactoryBot.create(:organization_member, organization: org1, user: user)
      member2 = FactoryBot.build(:organization_member, organization: org2, user: user)
      expect(member2).to be_valid
    end
  end
end
