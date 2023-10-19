# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GroupsController, "#index" do
  describe "list all groups" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:primary_mentor) { FactoryBot.create(:user) }

    context "when not authenticated" do
      before do
        get "/api/v1/groups", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized and not including assignments or group members" do
      before do
        # create 3 groups with user as group member for each
        FactoryBot.create_list(:group, 3, primary_mentor: primary_mentor).each do |g|
          FactoryBot.create(:group_member, group: g, user: user)
        end
        token = get_auth_token(user)
        get "/api/v1/groups",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns all groups signed in user is member of" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("groups")
        expect(response.parsed_body["data"].length).to eq(3)
      end
    end

    context "when authorized and including assignments" do
      before do
        # create 3 groups with assignment and group_member for each
        FactoryBot.create_list(:group, 3, primary_mentor: primary_mentor).each do |g|
          FactoryBot.create(:group_member, group: g, user: user)
          FactoryBot.create(:assignment, group: g)
        end
        token = get_auth_token(user)
        get "/api/v1/groups?include=assignments",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns all groups including assignments signed in user is member of" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("groups_with_assignments")
        expect(response.parsed_body["data"].length).to eq(3)
        expect(response.parsed_body["included"].length).to eq(3)
      end
    end

    context "when authorized and including group_members" do
      before do
        # create 3 groups with 4 group_members for each
        FactoryBot.create_list(:group, 3, primary_mentor: primary_mentor).each do |g|
          # creates new group member
          FactoryBot.create(:group_member, group: g, user: FactoryBot.create(:user))
          # Adds user as a group member so that the group is accessible to user
          FactoryBot.create(:group_member, group: g, user: user)
        end
        token = get_auth_token(user)
        get "/api/v1/groups?include=group_members",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns all groups including group_members signed in user is member of" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("groups_with_members")
        expect(response.parsed_body["data"].length).to eq(3)
        expect(response.parsed_body["included"].length).to eq(6)
      end
    end
  end
end
