# frozen_string_literal: true

require "rails_helper"

describe GroupMemberPolicy do
  subject { described_class.new(user, group_member) }

  let(:group_member) { @group_member }

  before do
    @owner = FactoryBot.create(:user)
    group = FactoryBot.create(:group, owner: @owner)
    @user = FactoryBot.create(:user)
    @group_member = FactoryBot.create(:group_member, group: group, user: @user)
  end

  context "user is owner" do
    let(:user) { @owner }

    it { is_expected.to permit(:owner) }
  end

  context "user is group member" do
    let(:user) { @user }

    it { is_expected.not_to permit(:owner) }
  end
end
