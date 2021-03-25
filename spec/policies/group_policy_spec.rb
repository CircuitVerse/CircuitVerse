# frozen_string_literal: true

require "rails_helper"

describe GroupPolicy do
  subject { described_class.new(user, group) }

  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
  end

  context "when the user is primary_mentor" do
    let(:user) { @primary_mentor }
    let(:group) { @group }

    it { is_expected.to permit(:show_access) }
    it { is_expected.to permit(:admin_access) }
  end

  context "when the user is a mentor" do
    before do
      @mentor = FactoryBot.create(:user)
      FactoryBot.create(:group_member, group: @group, user: @mentor, mentor: true)
    end

    let(:user) { @mentor }
    let(:group) { @group }

    it { is_expected.to permit(:show_access) }
    it { is_expected.not_to permit(:admin_access) }
    it { is_expected.to permit(:mentor_access) }
  end

  context "when the user is a group_member" do
    let(:user) { @member }
    let(:group) { @group }

    before do
      @member = FactoryBot.create(:user)
      FactoryBot.create(:group_member, group: @group, user: @member)
    end

    it { is_expected.to permit(:show_access) }
    it { is_expected.not_to permit(:admin_access) }
    it { is_expected.not_to permit(:mentor_access) }
  end

  context "when the user is not a group_member" do
    let(:user) { FactoryBot.create(:user) }
    let(:group) { @group }

    it { is_expected.not_to permit(:show_access) }
    it { is_expected.not_to permit(:admin_access) }
    it { is_expected.not_to permit(:mentor_access) }
  end
end
