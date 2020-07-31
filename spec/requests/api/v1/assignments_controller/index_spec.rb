# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AssignmentsController, "#index", type: :request do
  describe "list all assignments" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:mentor) { FactoryBot.create(:user) }
    let!(:group) { FactoryBot.create(:group, mentor: mentor) }
    let!(:group_member) { FactoryBot.create(:group_member, group: group, user: user) }
    let!(:assignments) { FactoryBot.create_list(:assignment, 3, group: group) }

    context "when not authenticated" do
      before do
        get "/api/v1/groups/#{group.id}/assignments", as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as random user and doesn't have access to assignments" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        get "/api/v1/groups/#{group.id}/assignments",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(403)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as mentor to fetch assignments" do
      before do
        token = get_auth_token(mentor)
        get "/api/v1/groups/#{group.id}/assignments",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns all assignments that belongs to the group" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("assignments")
        expect(response.parsed_body["data"].length).to eq(assignments.length)
      end
    end

    context "when authorized as group_member to fetch assignments" do
      before do
        token = get_auth_token(group_member.user)
        get "/api/v1/groups/#{group.id}/assignments",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns all assignments that belongs to the group" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("assignments")
        expect(response.parsed_body["data"].length).to eq(assignments.length)
      end
    end
  end
end
