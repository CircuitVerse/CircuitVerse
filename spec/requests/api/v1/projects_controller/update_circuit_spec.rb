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
          patch "/api/v1/projects/update_circuit", params: update_params, as: :json
        end

        it "returns 401 :unauthorized" do
          expect(response).to have_http_status(:unauthorized)
          expect(response.parsed_body).to have_jsonapi_errors
        end
      end

      context "when authenticated user is the author of the project" do
        before do
          token = get_auth_token(user)
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

      context "when project does not exist" do
        before do
          token = get_auth_token(user)
          patch "/api/v1/projects/update_circuit",
                headers: { Authorization: "Token #{token}" },
                params: { id: 0 }, as: :json
        end

        it "returns status not found" do
          expect(response).to have_http_status(:not_found)
          expect(response.parsed_body).to have_jsonapi_errors
        end
      end

      context "when project saving fails" do
        before do
          token = get_auth_token(user)
          friendly_finder = class_double(Project)
          allow(friendly_finder).to receive(:find).and_return(project)
          allow(Project).to receive(:friendly).and_return(friendly_finder)
          project_datum = instance_double(ProjectDatum, valid?: true, save: false, data: nil, "data=": nil)
          allow(project).to receive_messages(valid?: true, save: false, errors: double(full_messages: ["Save failed"]),
                                             project_datum: project_datum, build_project_datum: project_datum)
          patch "/api/v1/projects/update_circuit",
                headers: { Authorization: "Token #{token}" },
                params: update_params, as: :json
        end

        it "returns status unprocessable entity" do
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.parsed_body["status"]).to eq("error")
          expect(response.parsed_body["errors"]).not_to be_empty
        end
      end
    end
  end
end
