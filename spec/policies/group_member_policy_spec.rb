# frozen_string_literal: true

require "rails_helper"

describe GroupMemberPolicy do
  subject { described_class.new(user, group_member) }

  let(:group_member) { @group_member }

  before do
    @mentor = FactoryBot.create(:user)
    group = FactoryBot.create(:group, mentor: @mentor)
    @user = FactoryBot.create(:user)
    @group_member = FactoryBot.create(:group_member, group: group, user: @user)
  end

  context "user is mentor" do
    let(:user) { @mentor }

    it { is_expected.to permit(:mentor) }
  end

  context "user is group member" do
    let(:user) { @user }

    it { is_expected.not_to permit(:mentor) }
  end
end
