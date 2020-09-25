# frozen_string_literal: true

require "rails_helper"

describe GroupMemberPolicy do
  subject { GroupMemberPolicy.new(user, group_member) }
  let(:group_member) { @group_member }

  before do
    @owner = FactoryBot.create(:user)
    group = FactoryBot.create(:group, owner: @owner)
    @user = FactoryBot.create(:user)
    @group_member = FactoryBot.create(:group_member, group: group, user: @user)
  end

  context "user is owner" do
    let(:user) { @owner }
    it { should permit(:owner) }
  end

  context "user is group member" do
    let(:user) { @user }
    it { should_not permit(:owner) }
  end
end
