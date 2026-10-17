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
end
