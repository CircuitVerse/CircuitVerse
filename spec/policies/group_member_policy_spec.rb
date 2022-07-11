# frozen_string_literal: true

require "rails_helper"

describe GroupMemberPolicy do
  subject { described_class.new(user, group_member) }

  let(:group_member) { @group_member }

  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
    @user = FactoryBot.create(:user)
    @group_member = FactoryBot.create(:group_member, group: @group, user: @user)
  end

  context "when the user is primary_mentor" do
    let(:user) { @primary_mentor }

    it { is_expected.to permit(:primary_mentor) }
  end

  context "when the user is a mentor" do
    before do
      @mentor = FactoryBot.create(:user)
      FactoryBot.create(:group_member, group: @group, user: @mentor, mentor: true)
    end

    let(:user) { @mentor }

    it { is_expected.to permit(:mentor) }
    it { is_expected.not_to permit(:primary_mentor) }
  end

  context "when the user is group member" do
    let(:user) { @user }

    it { is_expected.not_to permit(:primary_mentor) }
    it { is_expected.not_to permit(:mentor) }
  end
end
