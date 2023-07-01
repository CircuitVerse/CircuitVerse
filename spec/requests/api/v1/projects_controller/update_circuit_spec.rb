# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#update_circuit", type: :request do
  describe "update circuit" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:random_user) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, author: user, name: "Test Name", project_access_type: "Public") }

    describe "#update_circuit" do
      let(:update_params) do
        {
          id: project.id,
          name: "Updated Name",
          image: ""
        }
      end

      context "when unauthenticated user tries to update project details" do
        before do
          patch "/api/v1/projects/update_circuit",
          params: update_params
        end

        it "returns 401 :unauthorized" do
          expect(response).to have_http_status(:unauthorized)
          expect(response.parsed_body).to have_jsonapi_errors
        end
      end

      context "when authenticated user is the author of the project" do
        before do
          token = get_auth_token(user)
          expect_any_instance_of(SimulatorHelper).to receive(:sanitize_data)
          patch "/api/v1/projects/update_circuit",
              headers: { Authorization: "Token #{token}" }, as: :json,
              params: update_params
        end

        it "updates project" do
          project.reload
          expect(project.name).to eq("Updated Name")
          expect(response).to have_http_status(:ok)
        end
      end

      context "when authenticated user is not the author of the project" do
        before do
          token = get_auth_token(random_user)
          patch "/api/v1/projects/update_circuit",
              headers: { Authorization: "Token #{token}" },
              params: update_params, as: :json
        end

        it "returns status unauthorized" do
          expect(response).to have_http_status(:forbidden)
          expect(response.parsed_body).to have_jsonapi_errors
        end
      end

      context "when authenticated user is a collaborator in the project" do
        before do
          token = get_auth_token(random_user)
          FactoryBot.create(:collaboration, user: random_user, project: project)
          expect_any_instance_of(SimulatorHelper).to receive(:sanitize_data)
          patch "/api/v1/projects/update_circuit",
              headers: { Authorization: "Token #{token}" },
              params: update_params, as: :json
        end

        it "updates project" do
          project.reload
          expect(project.name).to eq("Updated Name")
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end
end
