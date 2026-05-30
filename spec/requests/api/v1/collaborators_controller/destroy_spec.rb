# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::CollaboratorsController, "#destroy", type: :request do
  describe "delete specific collaborator" do
    let!(:author) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, author: author) }
    let!(:collaborator) { FactoryBot.create(:user) }
    let!(:collaboration) { FactoryBot.create(:collaboration, user: collaborator, project: project) }

    context "when not authenticated" do
      before do
        delete "/api/v1/projects/#{project.id}/collaborators/#{collaboration.user.id}", as: :json
      end

      it "returns status unauthenticated" do
        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated as random user and don't have author_access?" do
      before do
        token = get_auth_token(FactoryBot.create(:user))
        delete "/api/v1/projects/#{project.id}/collaborators/#{collaboration.user.id}",
               headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status unauthorized" do
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated but tries to delete non existent collaborator" do
      before do
        token = get_auth_token(author)
        delete "/api/v1/projects/#{project.id}/collaborators/0",
               headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "returns status not_found" do
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated and has access to delete collaborator" do
      before do
        token = get_auth_token(author)
        delete "/api/v1/projects/#{project.id}/collaborators/#{collaboration.user.id}",
               headers: { Authorization: "Token #{token}" }, as: :json
      end

      it "deletes collaborator & return status no_content" do
        expect { Collaboration.find_by!(user: collaborator, project: project) }.to raise_exception(
          ActiveRecord::RecordNotFound
        )
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
