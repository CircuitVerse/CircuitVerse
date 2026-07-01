# frozen_string_literal: true

require "rails_helper"

describe OrganizationGroupPolicy do
  subject { described_class.new(user, group) }

  before do
    @organization = FactoryBot.create(:organization)
    @admin = FactoryBot.create(:user)
    FactoryBot.create(:organization_member, organization: @organization, user: @admin, role: :admin)

    @mentor = FactoryBot.create(:user)
    FactoryBot.create(:organization_member, organization: @organization, user: @mentor, role: :mentor)

    @other_mentor = FactoryBot.create(:user)
    FactoryBot.create(:organization_member, organization: @organization, user: @other_mentor, role: :mentor)

    @group = FactoryBot.create(:group, primary_mentor: @mentor, organization: @organization)
  end

  context "when the user is a site admin" do
    let(:user) { FactoryBot.create(:user, admin: true) }
    let(:group) { @group }

    it { is_expected.to permit(:manage) }
  end

  context "when the user is an org admin" do
    let(:user) { @admin }
    let(:group) { @group }

    it { is_expected.to permit(:manage) }
  end

  context "when the user is the assigned mentor (primary_mentor) of the group" do
    let(:user) { @mentor }
    let(:group) { @group }

    it { is_expected.to permit(:manage) }
  end

  context "when the user is a co-mentor (in group_members) of the group" do
    before do
      @co_mentor = FactoryBot.create(:user)
      FactoryBot.create(:organization_member, organization: @organization, user: @co_mentor, role: :mentor)
      FactoryBot.create(:group_member, group: @group, user: @co_mentor, mentor: true)
    end

    let(:user) { @co_mentor }
    let(:group) { @group }

    it { is_expected.to permit(:manage) }
  end

  context "when the user is a mentor but NOT assigned to this group" do
    let(:user) { @other_mentor }
    let(:group) { @group }

    it { is_expected.not_to permit(:manage) }
  end

  context "when the user is a plain member" do
    before do
      @member = FactoryBot.create(:user)
      FactoryBot.create(:organization_member, organization: @organization, user: @member, role: :member)
    end

    let(:user) { @member }
    let(:group) { @group }

    it { is_expected.not_to permit(:manage) }
  end

  context "when the user is not a member of the organization" do
    let(:user) { FactoryBot.create(:user) }
    let(:group) { @group }

    it { is_expected.not_to permit(:manage) }
  end
end
