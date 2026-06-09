# frozen_string_literal: true

require "rails_helper"

describe OrganizationPolicy do
  subject { described_class.new(user, organization) }

  before do
    @organization = FactoryBot.create(:organization)
    @admin = FactoryBot.create(:user)
    FactoryBot.create(:organization_member, organization: @organization, user: @admin, role: :admin)
  end

  context "when the user is a site admin" do
    let(:user) { FactoryBot.create(:user, admin: true) }
    let(:organization) { @organization }

    it { is_expected.to permit(:show_access) }
    it { is_expected.to permit(:admin_access) }
    it { is_expected.to permit(:create_group) }
  end

  context "when the user is an org admin" do
    let(:user) { @admin }
    let(:organization) { @organization }

    it { is_expected.to permit(:show_access) }
    it { is_expected.to permit(:admin_access) }
    it { is_expected.to permit(:create_group) }
  end

  context "when the user is a mentor" do
    before do
      @mentor = FactoryBot.create(:user)
      FactoryBot.create(:organization_member, organization: @organization, user: @mentor, role: :mentor)
    end

    let(:user) { @mentor }
    let(:organization) { @organization }

    it { is_expected.to permit(:show_access) }
    it { is_expected.not_to permit(:admin_access) }
    it { is_expected.to permit(:create_group) }
    it { is_expected.to permit(:leave) }

    context "when the mentor owns a group in the organization" do
      before do
        FactoryBot.create(:group, primary_mentor: @mentor, organization: @organization)
      end

      it { is_expected.not_to permit(:leave) }
    end
  end

  context "when the user is a member" do
    before do
      @member = FactoryBot.create(:user)
      FactoryBot.create(:organization_member, organization: @organization, user: @member, role: :member)
    end

    let(:user) { @member }
    let(:organization) { @organization }

    it { is_expected.to permit(:show_access) }
    it { is_expected.not_to permit(:admin_access) }
    it { is_expected.not_to permit(:create_group) }
    it { is_expected.to permit(:leave) }
  end

  context "when the user is not a member" do
    let(:user) { FactoryBot.create(:user) }
    let(:organization) { @organization }

    it { is_expected.not_to permit(:admin_access) }
    it { is_expected.not_to permit(:create_group) }
    it { is_expected.not_to permit(:leave) }

    context "when the organization is public" do
      before { @organization.update!(private: false) }

      it { is_expected.to permit(:show_access) }
    end

    context "when the organization is private" do
      before { @organization.update!(private: true) }

      it { is_expected.not_to permit(:show_access) }
    end
  end

  context "when the org admin is the sole admin" do
    let(:user) { @admin }
    let(:organization) { @organization }

    it { is_expected.not_to permit(:leave) }
  end

  context "when there are multiple admins" do
    before do
      @second_admin = FactoryBot.create(:user)
      FactoryBot.create(:organization_member, organization: @organization, user: @second_admin, role: :admin)
    end

    let(:user) { @admin }
    let(:organization) { @organization }

    it { is_expected.to permit(:leave) }
  end
end
