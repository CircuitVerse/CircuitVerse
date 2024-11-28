# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::GroupsController, "#show", type: :request do
  describe "list specific group" do
    let!(:user) { create(:user) }
    let!(:primary_mentor) { create(:user) }
    let!(:group) { create(:group, primary_mentor: primary_mentor) }

    context "when not authenticated" do
      before do
        get "/api/v1/groups/#{group.id}", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as random user and don't have show_access?" do
      before do
        token = get_auth_token(create(:user))
        get "/api/v1/groups/#{group.id}",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to fetch details of non existent group" do
      before do
        token = get_auth_token(user)
        get "/api/v1/groups/0",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated and has access to group" do
      before do
        create(:group_member, user: user, group: group)
        token = get_auth_token(user)
        get "/api/v1/groups/#{group.id}",
            headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns the group details" do
        expect(response).to have_http_status(:ok)
        expect(response).to match_response_schema("group")
      end
    end
  end
end
