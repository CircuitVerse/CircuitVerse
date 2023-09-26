# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CollaboratorsController, "#create" do
  describe "create/add collaborators" do
    let!(:author) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, author: author) }
    let!(:user) { FactoryBot.create(:user) }

    context "when not authenticated" do
      before do
        post "/api/v1/projects/#{project.id}/collaborators/", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated as random user and don't have author_access?" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        post "/api/v1/projects/#{project.id}/collaborators/",
             headers: { Authorization: "Token #{token}" },
             params: create_params, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized but tries to add collaborator to non existent project" do
      before do
        token = get_auth_token(author)
        post "/api/v1/projects/0/collaborators/",
             headers: { Authorization: "Token #{token}" },
             params: create_params, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authorized and has access to add collaborator" do
      before do
        # creates a collaboration
        existing = FactoryBot.create(:user, email: "existing@test.com")
        FactoryBot.create(:collaboration, user: existing, project: project)
        token = get_auth_token(author)
        post "/api/v1/projects/#{project.id}/collaborators/",
             headers: { Authorization: "Token #{token}" },
             params: create_params, as: :json
      end

      it "returns status code 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns the added, already_existing & invalid mails (author being invalid)" do
        expect(response.parsed_body["added"]).to eq([user.email])
        puts user.email
        expect(response.parsed_body["existing"]).to eq(["existing@test.com"])
        expect(response.parsed_body["invalid"]).to eq(["invalid", author.email])
      end
    end

    def create_params
      {
        emails: "#{user.email}, existing@test.com, invalid, #{author.email}"
      }
    end
  end
end
