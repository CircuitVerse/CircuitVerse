require 'rails_helper'

RSpec.describe Group, type: :model do
  before do
    @mentor = FactoryBot.create(:user)
  end

  describe "associations" do
    it { should belong_to(:mentor) }
    it { should have_many(:users) }
    it { should have_many(:group_members) }
    it { should have_many(:assignments) }
    it { should have_many(:pending_invitations) }
  end

  describe "callbacks" do
    it "should call respective callbacks" do
      expect_any_instance_of(Group).to receive(:send_creation_mail)
      FactoryBot.create(:group, mentor: @mentor)
    end
  end

  describe "public methods" do
    it "should send group creation mail" do
      group = FactoryBot.create(:group, mentor: @mentor)
      expect {
        group.send_creation_mail
      }.to have_enqueued_job.on_queue('mailers')
    end
  end
end
