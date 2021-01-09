# frozen_string_literal: true

require "rails_helper"

describe GroupsController, type: :request do
  before do
    @mentor = FactoryBot.create(:user)
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, name: "test group", mentor: @mentor)
  end

  describe "#create" do
    it "creates a group" do
      sign_in @mentor
      expect do
        post groups_path, params: { group: { name: "test group", mentor_id: @mentor.id } }
      end.to change(Group, :count).by(1)
    end
  end

  describe "#destroy" do
    context "mentor is signed_in" do
      it "destroys group" do
        sign_in @mentor
        expect do
          delete group_path(@group)
        end.to change(Group, :count).by(-1)
      end
    end

    context "user other than mentor is signed in" do
      it "throws not authorized error" do
        sign_in_random_user
        delete group_path(@group)
        check_not_authorized(response)
      end
    end
  end

  describe "#show" do
    context "group member is signed in", :focus do
      before do
        @assignment = FactoryBot.create(:assignment, group: @group,
                                                     status: "reopening", deadline: Time.zone.now - 2.days)
        sign_in get_group_member(@group)
      end

      it "closes assignment and shows group" do
        get group_path(@group)
        @assignment.reload
        expect(@assignment.status).to eq("closed")
      end
    end

    context "random user is signed in" do
      it "throws not authorized error" do
        sign_in_random_user
        get group_path(@group)
        check_not_authorized(response)
      end
    end
  end

  describe "#update" do
    context "mentor is signed in" do
      it "updates group" do
        sign_in @mentor
        put group_path(@group), params: { group: { name: "updated group" } }
        @group.reload
        expect(@group.name).to eq("updated group")
      end
    end

    context "another user is signed in" do
      it "throws not authorized error" do
        sign_in_random_user
        put group_path(@group), params: { group: { name: "updated group" } }
        check_not_authorized(response)
      end
    end
  end

  describe "#invite" do
    before do
      @already_present = FactoryBot.create(:user)
      @group.update(token_expires_at: Time.zone.now + 12.days)
      FactoryBot.create(:group_member, user: @already_present, group: @group)
    end

    context "when user enters a valid link" do
      it "adds member to the group if group token matches" do
        sign_in @user
        expect do
          get invite_group_path(id: @group.id, token: @group.group_token)
        end.to change(GroupMember, :count).by(1)
      end
    end

    context "when user is already present in the group" do
      it "does not add member to the group" do
        sign_in @already_present
        expect do
          get invite_group_path(id: @group.id, token: @group.group_token)
        end.to change(GroupMember, :count).by(0)
      end
    end

    context "when user enters a expired url" do
      before do
        @group.update(token_expires_at: 1.day.ago)
      end

      it "does not add member to group and generates error message" do
        sign_in @user
        get invite_group_path(id: @group.id, token: @group.group_token)
        expect(response.status).to eq(302)
        expect(flash[:notice]).to eq("Url is expired, request a new one from owner of the group.")
      end
    end

    context "when user enters invalid url" do
      it "does not add member to the group and generates error message" do
        sign_in @user
        get invite_group_path(id: @group.id, token: "abc")
        expect(response.status).to eq(302)
      end
    end
  end

  describe "#generate_token" do
    before do
      @group.update(token_expires_at: 1.day.ago, group_token: nil)
    end

    context "when group does not have any token or token is expired" do
      it "regenerates the group token" do
        sign_in @mentor
        put generate_token_group_path(id: @group.id), xhr: true
        expect(response.status).to eq(200)
      end
    end
  end
end
