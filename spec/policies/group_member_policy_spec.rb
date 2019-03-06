require 'rails_helper'

describe GroupMemberPolicy do
  subject { GroupMemberPolicy.new(user, group_member) }
  let(:group_member) { @group_member }

  before do
    @mentor = FactoryBot.create(:user)
    group = FactoryBot.create(:group, mentor: @mentor)
    @user = FactoryBot.create(:user)
    @group_member = FactoryBot.create(:group_member, group: group, user: @user)
  end

  context 'user is mentor' do
    let(:user) { @mentor }
    it { should permit(:mentor) }
  end

  context 'user is group member' do
    let(:user) { @group_member }
    it { should_not permit(:mentor) }
  end
end
