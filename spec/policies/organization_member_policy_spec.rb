# frozen_string_literal: true

require "rails_helper"

describe OrganizationMemberPolicy do
  subject { described_class.new(user, organization_member) }

  before do
    @organization = FactoryBot.create(:organization)
    @admin = FactoryBot.create(:user)
    @admin_membership = FactoryBot.create(:organization_member, organization: @organization, user: @admin, role: :admin)
  end

  context "when the user is a site admin" do
    before do
      @member = FactoryBot.create(:user)
      @membership = FactoryBot.create(:organization_member, organization: @organization, user: @member, role: :member)
    end

    let(:user) { FactoryBot.create(:user, admin: true) }
    let(:organization_member) { @membership }

    it { is_expected.to permit(:admin_access) }
    it { is_expected.to permit(:update) }
    it { is_expected.to permit(:destroy) }
  end

  context "when the user is an org admin" do
    before do
      @member = FactoryBot.create(:user)
      @membership = FactoryBot.create(:organization_member, organization: @organization, user: @member, role: :member)
    end

    let(:user) { @admin }
    let(:organization_member) { @membership }

    it { is_expected.to permit(:admin_access) }
    it { is_expected.to permit(:update) }
    it { is_expected.to permit(:destroy) }
  end

  context "when the user is a mentor" do
    before do
      @mentor = FactoryBot.create(:user)
      @mentor_membership = FactoryBot.create(:organization_member, organization: @organization, user: @mentor,
                                                                   role: :mentor)
      @member = FactoryBot.create(:user)
      @membership = FactoryBot.create(:organization_member, organization: @organization, user: @member, role: :member)
    end

    let(:user) { @mentor }
    let(:organization_member) { @membership }

    it { is_expected.not_to permit(:admin_access) }
    it { is_expected.not_to permit(:update) }
    it { is_expected.not_to permit(:destroy) }
  end

  context "when the user is leaving themselves (destroy own membership)" do
    before do
      @member = FactoryBot.create(:user)
      @membership = FactoryBot.create(:organization_member, organization: @organization, user: @member, role: :member)
    end

    let(:user) { @member }
    let(:organization_member) { @membership }

    it { is_expected.to permit(:destroy) }
    it { is_expected.not_to permit(:update) }
  end

  context "when the sole admin tries to demote themselves" do
    let(:user) { @admin }
    let(:organization_member) { @admin_membership }

    it { is_expected.not_to permit(:update) }
  end

  context "when the sole admin tries to delete their own membership" do
    let(:user) { @admin }
    let(:organization_member) { @admin_membership }

    it { is_expected.not_to permit(:destroy) }
  end

  context "when there are multiple admins and one demotes the other" do
    before do
      @second_admin = FactoryBot.create(:user)
      @second_admin_membership = FactoryBot.create(:organization_member, organization: @organization,
                                                                         user: @second_admin, role: :admin)
    end

    let(:user) { @admin }
    let(:organization_member) { @second_admin_membership }

    it { is_expected.to permit(:update) }
    it { is_expected.to permit(:destroy) }
  end

  context "when a non-member tries to manage a membership" do
    before do
      @member = FactoryBot.create(:user)
      @membership = FactoryBot.create(:organization_member, organization: @organization, user: @member, role: :member)
    end

    let(:user) { FactoryBot.create(:user) }
    let(:organization_member) { @membership }

    it { is_expected.not_to permit(:admin_access) }
    it { is_expected.not_to permit(:update) }
    it { is_expected.not_to permit(:destroy) }
  end
end
