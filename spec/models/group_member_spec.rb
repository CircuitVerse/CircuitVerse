require 'rails_helper'

RSpec.describe GroupMember, type: :model do
  describe "associations" do
    it { should belong_to(:group) }
    it { should belong_to(:user) }
  end

  describe "callbacks" do
    before do
      @user = FactoryBot.create(:user)
      @group = FactoryBot.create(:group, mentor: @user)
    end

    it "should call respective callbacks" do
      expect_any_instance_of(GroupMember).to receive(:send_welcome_email)
      FactoryBot.create(:group_member, user: @user, group: @group)
    end
  end
end
