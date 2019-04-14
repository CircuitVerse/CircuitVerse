# frozen_string_literal: true

require "rails_helper"

describe GroupsController, type: :request do
  before do
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @mentor, name: "Test Group")
  end

  context "signed user requests group creation for another user" do
    it "does not create group" do
      sign_in FactoryBot.create(:user)
      request_params = [
        {
          type: "post",
          url: user_groups_path(@mentor),
          params: { group: { name: "Test", mentor_id: @mentor.id } }
        },
        {
          type: "put",
          url: user_group_path(@mentor, @group),
          params: { group: { name: "Test Change" } }
        },
        {
          type: "delete",
          url: user_group_path(@mentor, @group)
        },
        {
          type: "get",
          url: user_group_path(@mentor, @group)
        }
      ]

      authorization_checks request_params
    end
  end

  context "signed in user request group operations" do
    before do
      sign_in @mentor
    end

    describe "#create" do
      it "creates group" do
        expect do
          post user_groups_path(@mentor), params: { group: { name: "Test", mentor_id: @mentor.id } }
        end.to change { Group.count }.by(1)
      end
    end

    describe "#update" do
      it "updates group" do
        expect do
          expect do
            put user_groups_path(@mentor), params: { group: { name: "Test Change" } }
            @group.reload
          end.to change { @group.name }.to "Test Change"
        end
      end
    end

    describe "#destory" do
      it "deletes group" do
        expect do
          delete user_group_path(@mentor, @group)
        end.to change { Group.count }.by(-1)
      end
    end

    describe "#show" do
      it "shows group" do
        get user_group_path(@mentor, @group)
        expect(response.status).to eq(200)
        expect(response.body).to include(@group.name)
      end
    end

    describe "#new" do
      it "renders new group template" do
        get new_user_group_path(@mentor, @group)
        expect(response.status).to eq(200)
        expect(response.body).to include("New Group")
      end
    end

    describe "#edit" do
      it "renders edit group template" do
        get edit_user_group_path(@mentor, @group)
        expect(response.status).to eq(200)
        expect(response.body).to include("Editing Group")
      end
    end
  end
end
