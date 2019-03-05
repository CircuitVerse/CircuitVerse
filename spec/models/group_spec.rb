require 'rails_helper'

RSpec.describe Group, type: :model do
  describe "associations" do
    it { should belong_to(:mentor) }
    it { should have_many(:users) }
    it { should have_many(:group_members) }
    it { should have_many(:assignments) }
    it { should have_many(:pending_invitations) }
  end

  describe "callbacks" do
    before do
      @mentor = FactoryBot.create(:user)
    end

    it "should call respective callbacks" do
      expect_any_instance_of(Group).to receive(:send_creation_mail)
      FactoryBot.create(:group, mentor: @mentor)
    end
  end
end
