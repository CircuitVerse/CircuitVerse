# frozen_string_literal: true

require "rails_helper"

describe GroupsController, type: :request do
  before do
    @mentor = FactoryBot.create(:user)
  end

  describe "#create" do
    it "creates a group" do
      sign_in @mentor
      expect {
        post groups_path, params: { group: { name: "test group", mentor_id: @mentor.id } }
      }.to change { Group.count }.by(1)
    end
  end

  describe "#destroy" do
    before do
      @group = FactoryBot.create(:group, mentor: @mentor)
    end

    context "mentor is signed_in" do
      it "destroys group" do
        sign_in @mentor
        expect {
          delete group_path(@group)
        }.to change { Group.count }.by(-1)
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
    before do
      @group = FactoryBot.create(:group, mentor: @mentor)
    end

    context "group member is signed in", :focus do
      before do
        @assignment = FactoryBot.create(:assignment, group: @group,
          status: "reopening", deadline: Time.now - 2.days)
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
    before do
      @group = FactoryBot.create(:group, name: "test group", mentor: @mentor)
    end

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
end
