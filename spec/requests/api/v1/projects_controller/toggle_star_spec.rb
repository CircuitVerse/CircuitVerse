# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#toggle_star", type: :request do
  describe "toggle starred condition for a particular project" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, author: user) }

    context "when not authenticated" do
      before do
        get "/api/v1/projects/#{project.id}/toggle-star", as: :json
      end

      it "returns status :not_authorized" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated & stars a non existent project" do
      before do
        token = get_auth_token(user)
        get "/api/v1/projects/0/toggle-star",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status :not_found" do
        expect(response).to have_http_status(404)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when stars an unstarred project" do
      before do
        token = get_auth_token(user)
        get "/api/v1/projects/#{project.id}/toggle-star",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status :ok & starred message" do
        expect(response).to have_http_status(200)
        expect(response.parsed_body["message"]).to eq("Starred successfully!")
      end
    end

    context "when unstars a starred project" do
      before do
        FactoryBot.create(:star, project: project, user: user)
        token = get_auth_token(user)
        get "/api/v1/projects/#{project.id}/toggle-star",
            headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "returns status :ok & starred message" do
        expect(response).to have_http_status(200)
        expect(response.parsed_body["message"]).to eq("Unstarred successfully!")
      end
    end
  end
end
