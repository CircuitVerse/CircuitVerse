# frozen_string_literal: true

require "rails_helper"

RSpec.describe GroupMentor, type: :model do
  before do
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, owner: @user)
  end

  describe "associations" do
    it { should belong_to(:group) }
    it { should belong_to(:user) }
  end

  describe "callbacks" do
    it "should call respective callbacks" do
      expect_any_instance_of(GroupMentor).to receive(:send_welcome_email)
      FactoryBot.create(:group_mentor, user: @user, group: @group)
    end
  end

  describe "public methods" do
    it "sends welcome email" do
      group_mentor = FactoryBot.create(:group_mentor, user: @user, group: @group)
      expect {
        group_mentor.send_welcome_email
      }.to have_enqueued_job.on_queue("mailers")
    end
  end
end
