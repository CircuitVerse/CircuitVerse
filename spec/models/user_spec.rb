# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:projects) }
    it { should have_many(:stars) }
    it { should have_many(:rated_projects) }
    it { should have_many(:groups_mentored) }
    it { should have_many(:group_members) }
    it { should have_many(:groups) }
    it { should have_many(:collaborations) }
    it { should have_many(:collaborated_projects) }
  end

  describe "callbacks" do
    it "should send mail and invites on creation" do
      expect_any_instance_of(User).to receive(:send_welcome_mail)
      expect_any_instance_of(User).to receive(:create_members_from_invitations)
      FactoryBot.create(:user)
    end
  end

  describe "validations" do
    it { should have_attached_file(:profile_picture) }
    it { should validate_attachment_content_type(:profile_picture)
                  .allowing("image/png", "image/jpeg", "image/jpg") }
  end

  describe "public methods" do
    before do
      mentor = FactoryBot.create(:user)
      group = FactoryBot.create(:group, mentor: mentor)
      @user = FactoryBot.create(:user)
      FactoryBot.create(:pending_invitation, group: group, email: @user.email)
    end

    it "sends welcome mail" do
      expect {
        @user.send(:send_welcome_mail)
      }.to have_enqueued_job.on_queue("mailers")
    end

    it "Create member records from invitations" do
      expect {
        @user.create_members_from_invitations
      }.to change { PendingInvitation.count }.by(-1)
       .and change { GroupMember.count }.by(1)
    end
  end
end
