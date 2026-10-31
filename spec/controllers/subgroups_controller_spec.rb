# frozen_string_literal: true

require "rails_helper"

describe SubgroupsController, type: :request do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
  end

  describe "#create" do
    context "when the primary mentor is signed in" do
      it "creates a subgroup under the group" do
        sign_in @primary_mentor
        expect do
          post group_subgroups_path(@group), params: { group: { name: "Team A" } }
        end.to change(@group.subgroups, :count).by(1)
        expect(@group.subgroups.last.name).to eq("Team A")
      end
    end

    context "when a co-mentor is signed in" do
      it "creates a subgroup under the group" do
        sign_in_group_mentor(@group)
        expect do
          post group_subgroups_path(@group), params: { group: { name: "Team A" } }
        end.to change(@group.subgroups, :count).by(1)
      end
    end

    context "when the subgroup is invalid" do
      it "does not create a subgroup and redirects with an error" do
        sign_in @primary_mentor
        expect do
          post group_subgroups_path(@group), params: { group: { name: "" } }
        end.not_to change(@group.subgroups, :count)
        expect(response).to redirect_to(group_path(@group))
      end
    end

    context "when a random user is signed in" do
      it "throws not authorized error" do
        sign_in_random_user
        post group_subgroups_path(@group), params: { group: { name: "Team A" } }
        check_not_authorized(response)
      end
    end
  end

  describe "#destroy" do
    before do
      @subgroup = FactoryBot.create(:group, name: "Team A", parent_group: @group)
    end

    context "when the primary mentor is signed in" do
      it "destroys the subgroup" do
        sign_in @primary_mentor
        expect do
          delete group_subgroup_path(@group, @subgroup)
        end.to change(@group.subgroups, :count).by(-1)
      end
    end

    context "when a random user is signed in" do
      it "throws not authorized error" do
        sign_in_random_user
        delete group_subgroup_path(@group, @subgroup)
        check_not_authorized(response)
      end
    end
  end

  describe "#update_members" do
    before do
      @subgroup = FactoryBot.create(:group, name: "Team A", parent_group: @group)
      @student = FactoryBot.create(:user)
      @other_student = FactoryBot.create(:user)
      @outsider = FactoryBot.create(:user)
      [@student, @other_student].each { |user| FactoryBot.create(:group_member, group: @group, user: user) }
    end

    def sync(user_ids)
      patch update_members_group_subgroup_path(@group, @subgroup), params: { user_ids: user_ids }
    end

    context "when the primary mentor is signed in" do
      before { sign_in @primary_mentor }

      it "adds parent group members to the subgroup" do
        sync([@student.id, @other_student.id])
        expect(response).to redirect_to(group_path(@subgroup))
        expect(@subgroup.group_members.pluck(:user_id)).to contain_exactly(@student.id, @other_student.id)
      end

      it "removes members that are no longer selected" do
        FactoryBot.create(:group_member, group: @subgroup, user: @student)
        sync([@other_student.id])
        expect(@subgroup.group_members.pluck(:user_id)).to contain_exactly(@other_student.id)
      end

      it "ignores users who are not in the parent group" do
        sync([@outsider.id])
        expect(@subgroup.group_members.count).to eq(0)
      end

      it "neither duplicates nor demotes an existing subgroup mentor" do
        FactoryBot.create(:group_member, group: @subgroup, user: @student, mentor: true)
        sync([@student.id, @other_student.id])
        rows = @subgroup.group_members.where(user_id: @student.id)
        expect(rows.count).to eq(1)
        expect(rows.first.mentor).to be(true)
      end

      it "keeps mentor rows when they are not selected" do
        FactoryBot.create(:group_member, group: @subgroup, user: @student, mentor: true)
        sync([@other_student.id])
        expect(@subgroup.group_members.mentor.pluck(:user_id)).to contain_exactly(@student.id)
      end

      it "does not send welcome emails" do
        expect { sync([@student.id]) }.not_to have_enqueued_mail(GroupMailer, :new_member_email)
      end
    end

    context "when a random user is signed in" do
      it "throws not authorized error" do
        sign_in_random_user
        sync([@student.id])
        check_not_authorized(response)
        expect(@subgroup.group_members.count).to eq(0)
      end
    end
  end

  describe "#update_team_project" do
    before do
      @subgroup = FactoryBot.create(:group, name: "Team A", parent_group: @group)
      @student = FactoryBot.create(:user)
      @teammate = FactoryBot.create(:user)
      [@student, @teammate].each do |user|
        FactoryBot.create(:group_member, group: @group, user: user)
        FactoryBot.create(:group_member, group: @subgroup, user: user)
      end
      @project = FactoryBot.create(:project, author: @student)
    end

    def designate(project)
      patch update_team_project_group_subgroup_path(@group, @subgroup), params: { project_id: project.id }
    end

    context "when the primary mentor is signed in" do
      before { sign_in @primary_mentor }

      it "designates the project and adds the other members as collaborators" do
        designate(@project)
        expect(@subgroup.reload.team_project).to eq(@project)
        expect(@project.collaborators).to contain_exactly(@teammate)
      end

      it "does not duplicate collaborators when run twice" do
        2.times { designate(@project) }
        expect(@project.collaborations.count).to eq(1)
      end

      it "adds new subgroup members as collaborators on the next sync" do
        designate(@project)
        newcomer = FactoryBot.create(:user)
        FactoryBot.create(:group_member, group: @group, user: newcomer)
        patch update_members_group_subgroup_path(@group, @subgroup),
              params: { user_ids: [@student.id, @teammate.id, newcomer.id] }
        expect(@project.collaborators).to contain_exactly(@teammate, newcomer)
      end

      it "rejects a project whose author is not in the subgroup" do
        designate(FactoryBot.create(:project, author: FactoryBot.create(:user)))
        expect(@subgroup.reload.team_project).to be_nil
        expect(Collaboration.count).to eq(0)
      end
    end

    context "when a random user is signed in" do
      it "throws not authorized error" do
        sign_in_random_user
        designate(@project)
        check_not_authorized(response)
        expect(@subgroup.reload.team_project).to be_nil
      end
    end
  end
end
