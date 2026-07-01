# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:organization_members).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:organization_members) }
    it { is_expected.to have_many(:groups).dependent(:nullify) }
  end

  describe "validations" do
    subject { FactoryBot.build(:organization) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:slug).case_insensitive }

    describe "links count" do
      it "is valid with 5 or fewer links" do
        org = FactoryBot.build(:organization, links: ["https://a.com", "https://b.com"])
        expect(org).to be_valid
      end

      it "is invalid with more than 5 links" do
        org = FactoryBot.build(:organization, links: [
                                 "https://a.com", "https://b.com", "https://c.com",
                                 "https://d.com", "https://e.com", "https://f.com"
                               ])
        expect(org).not_to be_valid
        expect(org.errors[:links]).to include("cannot have more than 5 links")
      end
    end
  end

  describe "slug generation" do
    it "automatically generates a slug from the name" do
      org = FactoryBot.create(:organization, name: "My Test Org")
      expect(org.slug).to be_present
      expect(org.slug).to eq("my-test-org")
    end

    it "generates a unique slug when names would collide" do
      org1 = FactoryBot.create(:organization, name: "Collision Org")
      org2 = FactoryBot.create(:organization, name: "Collision Org 2")
      expect(org1.slug).not_to eq(org2.slug)
    end
  end

  describe "callbacks" do
    describe "#purge_logo before_destroy" do
      it "purges the logo attachment when the organization is destroyed" do
        org = FactoryBot.create(:organization)
        allow(org.logo).to receive(:attached?).and_return(true)
        allow(org.logo).to receive(:purge)
        org.destroy
        expect(org.logo).to have_received(:purge)
      end
    end

    describe "#remove_logo before_validation" do
      it "purges logo when remove_logo is set to '1'" do
        org = FactoryBot.create(:organization)
        allow(org.logo).to receive(:purge)
        org.remove_logo = "1"
        org.valid?
        expect(org.logo).to have_received(:purge)
      end
    end
  end

  describe "dependent behaviour" do
    it "destroys all organization_members when the organization is deleted" do
      org = FactoryBot.create(:organization)
      user = FactoryBot.create(:user)
      FactoryBot.create(:organization_member, organization: org, user: user)

      expect { org.destroy }.to change(OrganizationMember, :count).by(-1)
    end

    it "nullifies the organization_id on groups when the organization is deleted" do
      org = FactoryBot.create(:organization)
      mentor = FactoryBot.create(:user)
      group = FactoryBot.create(:group, primary_mentor: mentor, organization: org)

      org.destroy
      expect(group.reload.organization_id).to be_nil
    end
  end
end
