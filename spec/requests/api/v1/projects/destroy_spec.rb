# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#destroy", type: :request do
  describe "destroy specific project" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:random_user) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, author: user) }

    context "when not authenticated" do
      before(:each) do
        delete "/api/v1/projects/#{project.id}", as: :json
      end
      it "should return status unauthorized" do
        expect(response).to have_http_status(401)
        expect(response.parsed_body).to have_jsonapi_errors()
      end
    end

    context "when authenticated user tries to delete other user's project" do
      before(:each) do
        token = get_auth_token(random_user)
        delete "/api/v1/projects/#{project.id}",
        headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "should return status :forbidden" do
        expect(response).to have_http_status(403)
        expect(response.parsed_body).to have_jsonapi_errors()
      end
    end

    context "when authenticated user tries to delete own project" do
      before(:each) do
        token = get_auth_token(user)
        delete "/api/v1/projects/#{project.id}",
        headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "should delete project & return status :no_content" do
        expect(response).to have_http_status(204)
      end
    end

    context "when authenticated user tries to destroy non existent project details" do
      before(:each) do
        token = get_auth_token(random_user)
        delete "/api/v1/projects/0",
        headers: { "Authorization": "Token #{token}" }, as: :json
      end

      it "should return status :not_found" do
        expect(response).to have_http_status(404)
        expect(response.parsed_body).to have_jsonapi_errors()
      end
    end
  end
end
