# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:projects) }
    it { is_expected.to have_many(:stars) }
    it { is_expected.to have_many(:rated_projects) }
    it { is_expected.to have_many(:groups_owned) }
    it { is_expected.to have_many(:group_members) }
    it { is_expected.to have_many(:groups) }
    it { is_expected.to have_many(:collaborations) }
    it { is_expected.to have_many(:collaborated_projects) }
    it { is_expected.to have_many(:noticed_notifications) }
  end

  describe "callbacks" do
    it "sends mail and invites on creation" do
      expect_any_instance_of(described_class).to receive(:send_welcome_mail)
      expect_any_instance_of(described_class).to receive(:create_members_from_invitations)
      FactoryBot.create(:user)
    end
  end

  describe "validations" do
    before do
      profile_picture = fixture_file_upload("profile.png", "image/png")
      @user = FactoryBot.create(:user, profile_picture: profile_picture)
    end

    it "validates active storage attachment" do
      expect(@user.profile_picture).to be_attached
    end

    it "validates file name and file type" do
      expect(@user.profile_picture.filename).to eq("profile.png")
      expect(@user.profile_picture.content_type).to eq("image/png")
    end
  end

  describe "public methods" do
    before do
      primary_mentor = FactoryBot.create(:user)
      group = FactoryBot.create(:group, primary_mentor: primary_mentor)
      @user = FactoryBot.create(:user)
      FactoryBot.create(:pending_invitation, group: group, email: @user.email)
    end

    it "sends welcome mail" do
      expect do
        @user.send(:send_welcome_mail)
      end.to have_enqueued_job.on_queue("mailers")
    end

    it "Create member records from invitations" do
      expect do
        @user.create_members_from_invitations
      end.to change(PendingInvitation, :count).by(-1)
                                              .and change(GroupMember, :count).by(1)
    end

    it "user is not moderator by default" do
      expect(@user).not_to be_moderator
    end
  end
end
