require 'rails_helper'

RSpec.describe PendingInvitation, type: :model do
  before do
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @mentor)
  end

  describe "associations" do
    it { should belong_to(:group) }
  end

  describe "callbacks", :focus do
    it "should all respective callbacks" do
      expect_any_instance_of(PendingInvitation).to receive(:send_pending_invitation_mail)
      FactoryBot.create(:pending_invitation, group: @group)
    end
  end

  describe "public methods" do
    it 'sends pending invitation mail' do
      invitation = FactoryBot.create(:pending_invitation, group: @group)
      expect {
        invitation.send_pending_invitation_mail
      }.to have_enqueued_job.on_queue('mailers')
    end
  end
end
