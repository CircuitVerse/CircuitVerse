# frozen_string_literal: true

require "rails_helper"

describe GroupPolicy do
  subject { described_class.new(user, group) }

  before do
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @mentor)
  end

  context "user is mentor" do
    let(:user) { @mentor }
    let(:group) { @group }

    it { is_expected.to permit(:show_access) }
    it { is_expected.to permit(:admin_access) }
  end

  context "user is a group_member" do
    let(:user) { @member }
    let(:group) { @group }

    before do
      @member = FactoryBot.create(:user)
      FactoryBot.create(:group_member, group: @group, user: @member)
    end

    it { is_expected.to permit(:show_access) }
    it { is_expected.not_to permit(:admin_access) }
  end

  context "user is not a group_member" do
    let(:user) { FactoryBot.create(:user) }
    let(:group) { @group }

    it { is_expected.not_to permit(:show_access) }
    it { is_expected.not_to permit(:admin_access) }
  end
end
