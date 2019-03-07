require 'rails_helper'

RSpec.describe PendingInvitation, type: :model do
  describe "associations" do
    it { should belong_to(:group) }
  end

  describe "callbacks", :focus do
    before do
      @mentor = FactoryBot.create(:user)
      @group = FactoryBot.create(:group, mentor: @mentor)
    end

    it "should all respective callbacks" do
      expect_any_instance_of(PendingInvitation).to receive(:send_pending_invitation_mail)
      FactoryBot.create(:pending_invitation, group: @group)
    end
  end
end
