# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::AssignmentsController, "#start", type: :request do
  describe "start working on assignment" do
    let!(:assignment) do
      FactoryBot.create(
        :assignment, group: FactoryBot.create(:group, mentor: FactoryBot.create(:user))
      )
    end
    let!(:closed_assignment) do
      FactoryBot.create(
        :assignment, group: FactoryBot.create(
          :group, mentor: FactoryBot.create(:user)
        ), status: "closed"
      )
    end

    context "when not authenticated" do
      before do
        get "/api/v1/assignments/#{assignment.id}/start", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to start closed assignment" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        get "/api/v1/assignments/#{closed_assignment.id}/start",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(403)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to start non existent assignment" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        get "/api/v1/assignments/0/start",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(404)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized and starts assignment" do
      before do
        @user = FactoryBot.create(:user)
        token = get_auth_token(@user)
        get "/api/v1/assignments/#{assignment.id}/start",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "starts a new project & return status ok" do
        assignment_proj_name = "#{@user.name}/#{assignment.name}"
        expect(response).to have_http_status(200)
        expect(@user.projects).to include(Project.find_by(name: assignment_proj_name))
      end
    end
  end
end
