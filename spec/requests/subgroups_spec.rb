# frozen_string_literal: true

require "rails_helper"

describe SubgroupsController, type: :request do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
    @student = FactoryBot.create(:user)
    FactoryBot.create(:group_member, group: @group, user: @student)
  end

  describe "#create" do
    context "when signed in as the primary mentor" do
      before { sign_in @primary_mentor }

      it "creates a subgroup under the group" do
        expect do
          post group_subgroups_path(@group), params: { group: { name: "Team A" } }
        end.to change(Group, :count).by(1)
        expect(response).to redirect_to(group_path(@group))
        subgroup = Group.order(:created_at).last
        expect(subgroup.parent_group).to eq(@group)
        expect(subgroup.primary_mentor).to eq(@primary_mentor)
      end

      it "rejects a duplicate subgroup name with an alert" do
        FactoryBot.create(:group, name: "Team A", parent_group: @group)
        expect do
          post group_subgroups_path(@group), params: { group: { name: "Team A" } }
        end.not_to change(Group, :count)
        expect(flash[:alert]).to be_present
      end
    end

    context "when signed in as a group mentor" do
      before do
        mentor = FactoryBot.create(:user)
        FactoryBot.create(:group_member, group: @group, user: mentor, mentor: true)
        sign_in mentor
      end

      it "creates a subgroup" do
        expect do
          post group_subgroups_path(@group), params: { group: { name: "Team A" } }
        end.to change(Group, :count).by(1)
      end
    end

    context "when signed in as a regular member" do
      before { sign_in @student }

      it "is not authorized" do
        expect do
          post group_subgroups_path(@group), params: { group: { name: "Team A" } }
        end.not_to change(Group, :count)
      end
    end

    context "when the target group is itself a subgroup" do
      before { sign_in @primary_mentor }

      it "is not authorized (no nesting)" do
        subgroup = FactoryBot.create(:group, name: "Team A", parent_group: @group)
        expect do
          post group_subgroups_path(subgroup), params: { group: { name: "Nested" } }
        end.not_to change(Group, :count)
      end
    end
  end

  describe "#destroy" do
    before do
      @subgroup = FactoryBot.create(:group, name: "Team A", parent_group: @group)
    end

    context "when signed in as the primary mentor" do
      before { sign_in @primary_mentor }

      it "deletes the subgroup" do
        expect do
          delete group_subgroup_path(@group, @subgroup)
        end.to change(Group, :count).by(-1)
        expect(response).to redirect_to(group_path(@group))
      end
    end

    context "when signed in as a regular member" do
      before { sign_in @student }

      it "is not authorized" do
        expect do
          delete group_subgroup_path(@group, @subgroup)
        end.not_to change(Group, :count)
      end
    end
  end

  describe "#update_members" do
    before do
      @subgroup = FactoryBot.create(:group, name: "Team A", parent_group: @group)
      @other_student = FactoryBot.create(:user)
      FactoryBot.create(:group_member, group: @group, user: @other_student)
      @outsider = FactoryBot.create(:user)
      sign_in @primary_mentor
    end

    it "adds selected parent members to the subgroup" do
      patch update_members_group_subgroup_path(@group, @subgroup),
            params: { user_ids: [@student.id, @other_student.id] }
      expect(@subgroup.reload.group_members.pluck(:user_id))
        .to contain_exactly(@student.id, @other_student.id)
    end

    it "removes deselected members from the subgroup" do
      FactoryBot.create(:group_member, group: @subgroup, user: @student)
      patch update_members_group_subgroup_path(@group, @subgroup),
            params: { user_ids: [@other_student.id] }
      expect(@subgroup.reload.group_members.pluck(:user_id))
        .to contain_exactly(@other_student.id)
    end

    it "clears membership when no users are submitted" do
      FactoryBot.create(:group_member, group: @subgroup, user: @student)
      patch update_members_group_subgroup_path(@group, @subgroup), params: {}
      expect(@subgroup.reload.group_members.count).to eq(0)
    end

    it "ignores users who are not members of the parent group" do
      patch update_members_group_subgroup_path(@group, @subgroup),
            params: { user_ids: [@outsider.id, @student.id] }
      expect(@subgroup.reload.group_members.pluck(:user_id))
        .to contain_exactly(@student.id)
    end
  end

  describe "invite token" do
    it "cannot be generated for a subgroup" do
      subgroup = FactoryBot.create(:group, name: "Team A", parent_group: @group)
      sign_in @primary_mentor
      put generate_token_group_path(subgroup)
      expect(response).to have_http_status(:forbidden)
      expect(subgroup.reload.token_expires_at).to be_nil
    end
  end

  describe "group pages with subgroups" do
    before do
      @subgroup = FactoryBot.create(:group, name: "Team Alpha", parent_group: @group)
    end

    context "when the mentor views the parent group" do
      it "renders the subgroups section with manage controls" do
        sign_in @primary_mentor
        get group_path(@group)
        expect(response.body).to include("SUBGROUPS:")
        expect(response.body).to include("Team Alpha")
        expect(response.body).to include("createsubgroupModal")
      end
    end

    context "when a student not in any subgroup views the parent group" do
      it "does not list other teams and shows no manage controls" do
        sign_in @student
        get group_path(@group)
        expect(response.body).not_to include("Team Alpha")
        expect(response.body).not_to include("createsubgroupModal")
      end
    end

    context "when a subgroup member views the parent group" do
      it "lists their subgroup" do
        FactoryBot.create(:group_member, group: @subgroup, user: @student)
        sign_in @student
        get group_path(@group)
        expect(response.body).to include("Team Alpha")
      end
    end

    context "when the mentor views the subgroup page" do
      it "shows the parent breadcrumb and the manage-members modal instead of invites" do
        sign_in @primary_mentor
        get group_path(@subgroup)
        expect(response.body).to include("Subgroup of:")
        expect(response.body).to include("managesubgroupmembersModal")
        expect(response.body).not_to include("addmemberModal")
        expect(response.body).not_to include("createsubgroupModal")
      end
    end

    context "when a subgroup member views the subgroup page" do
      it "renders without manage controls" do
        FactoryBot.create(:group_member, group: @subgroup, user: @student)
        sign_in @student
        get group_path(@subgroup)
        expect(response).to have_http_status(:ok)
        expect(response.body).not_to include("managesubgroupmembersModal")
      end
    end
  end
end
