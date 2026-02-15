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

  describe "dependent destroy behavior" do
    let(:user) { FactoryBot.create(:user) }
    let(:project1) { FactoryBot.create(:project, project_access_type: "Public") }
    let(:project2) { FactoryBot.create(:project, project_access_type: "Public") }

    before do
      # Create stars for this user
      FactoryBot.create(:star, user: user, project: project1)
      FactoryBot.create(:star, user: user, project: project2)
    end

    describe "destroying a user" do
      it "destroys associated stars" do
        expect {
          user.destroy
        }.to change(Star, :count).by(-2)
      end

      it "does not destroy projects that were starred" do
        user.destroy
        expect(Project.exists?(project1.id)).to be true
        expect(Project.exists?(project2.id)).to be true
      end

      it "removes user from rated_projects association" do
        expect(user.rated_projects).to include(project1, project2)
        user.destroy
        expect(User.find_by(id: user.id)).to be_nil
      end

      it "removes stars_count from projects" do
        project1.reload
        expect(project1.stars_count).to eq(1)
        user.destroy
        project1.reload
        expect(project1.stars_count).to eq(0)
      end
    end

    describe "rated_projects through association" do
      it "returns projects starred by the user" do
        expect(user.rated_projects).to match_array([project1, project2])
      end

      it "does not include unstarred projects" do
        unstarred_project = FactoryBot.create(:project, project_access_type: "Public")
        expect(user.rated_projects).not_to include(unstarred_project)
      end

      it "respects project access types" do
        private_project = FactoryBot.create(:project, project_access_type: "Private")
        FactoryBot.create(:star, user: user, project: private_project)
        user.reload
        expect(user.rated_projects).to include(private_project)
      end
    end
  end

  describe "grades destruction" do
    let(:user) { FactoryBot.create(:user) }
    let(:group) { FactoryBot.create(:group, primary_mentor: user) }
    let(:assignment) { FactoryBot.create(:assignment, group: group) }
    let(:project) { FactoryBot.create(:project, assignment: assignment) }

    before do
      FactoryBot.create(:grade, project: project, grader: user, assignment: assignment)
      FactoryBot.create(:grade, project: project, grader: user, assignment: assignment, grade: "B")
    end

    it "destroys grades created by the user" do
      expect {
        user.destroy
      }.to change(Grade, :count).by(-2)
    end

    it "does not destroy the graded project" do
      project_id = project.id
      user.destroy
      expect(Project.exists?(project_id)).to be true
    end

    it "removes grades_count from projects" do
      project.reload
      expect(project.grades.count).to eq(2)
      user.destroy
      project.reload
      expect(project.grades.count).to eq(0)
    end
  end

  describe "collaborations destruction" do
    let(:user) { FactoryBot.create(:user) }
    let(:project) { FactoryBot.create(:project, project_access_type: "Public") }

    before do
      FactoryBot.create(:collaboration, user: user, project: project)
    end

    it "destroys collaborations when user is deleted" do
      expect {
        user.destroy
      }.to change(Collaboration, :count).by(-1)
    end

    it "does not destroy the collaborated project" do
      project_id = project.id
      user.destroy
      expect(Project.exists?(project_id)).to be true
    end
  end

  describe "submissions destruction" do
    let(:user) { FactoryBot.create(:user) }
    let(:contest) { FactoryBot.create(:contest) }
    let(:project) { FactoryBot.create(:project, project_access_type: "Public") }

    before do
      FactoryBot.create(:submission, user: user, contest: contest, project: project)
    end

    it "destroys submissions when user is deleted" do
      expect {
        user.destroy
      }.to change(Submission, :count).by(-1)
    end
  end
end

