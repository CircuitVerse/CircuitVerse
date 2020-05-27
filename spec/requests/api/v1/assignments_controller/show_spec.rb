# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AssignmentsController, "#show", type: :request do
  describe "list specific assignment" do
    let!(:group) { FactoryBot.create(:group, mentor: FactoryBot.create(:user)) }
    let!(:group_member) { FactoryBot.create(
      :group_member, group: group, user: FactoryBot.create(:user)
    )}
    let!(:assignment) { FactoryBot.create(:assignment, group: group) }

    context "when not authenticated" do
      before do
        get "/api/v1/assignments/#{assignment.id}", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized as random user and don't have show_access?" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        get "/api/v1/assignments/#{assignment.id}",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(403)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to fetch details of non existent assignment" do
      before do
        token = get_auth_token(group_member.user)
        get "/api/v1/assignments/0",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(404)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized and has access to fetch assignment" do
      before do
        token = get_auth_token(group_member.user)
        get "/api/v1/assignments/#{assignment.id}",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns the group details" do
        expect(response).to have_http_status(200)
        expect(response).to match_response_schema("assignment")
      end
    end
  end
end
