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

      context "when image data is provided", :skip_windows do
        let(:update_params_with_image) do
          {
            id: project.id,
            name: "Updated Name",
            image: "data:image/jpeg;base64,#{Faker::Alphanumeric.alpha(number: 20)}"
          }
        end

        it "attaches a circuit preview to the project" do
          token = get_auth_token(user)
          patch "/api/v1/projects/update_circuit",
                headers: { Authorization: "Token #{token}" },
                params: update_params_with_image, as: :json

          project.reload
          expect(response).to have_http_status(:ok)
          expect(project.circuit_preview).to be_attached
          expect(project.circuit_preview.filename.to_s).to start_with("preview_")
          expect(project.circuit_preview.content_type).to eq("image/jpeg")
        end

        it "purges the previously attached circuit preview before attaching the new one" do
          token = get_auth_token(user)
          patch "/api/v1/projects/update_circuit",
                headers: { Authorization: "Token #{token}" },
                params: update_params_with_image, as: :json
          project.reload
          first_blob_id = project.circuit_preview.blob.id

          patch "/api/v1/projects/update_circuit",
                headers: { Authorization: "Token #{token}" },
                params: update_params_with_image, as: :json
          project.reload

          expect(project.circuit_preview).to be_attached
          expect(project.circuit_preview.blob.id).not_to eq(first_blob_id)
          expect(ActiveStorage::Blob.exists?(first_blob_id)).to be false
        end
      end

      context "when image data is blank but a circuit preview is already attached" do
        before do
          project.circuit_preview.attach(
            io: StringIO.new(Base64.decode64(Faker::Alphanumeric.alpha(number: 20))),
            filename: "preview_existing.jpeg",
            content_type: "image/jpeg"
          )
        end

        it "keeps the existing circuit preview instead of purging it" do
          token = get_auth_token(user)
          patch "/api/v1/projects/update_circuit",
                headers: { Authorization: "Token #{token}" },
                params: update_params, as: :json

          project.reload
          expect(response).to have_http_status(:ok)
          expect(project.circuit_preview).to be_attached
          expect(project.circuit_preview.filename.to_s).to eq("preview_existing.jpeg")
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
          allow_any_instance_of(Project).to receive(:save).and_return(false)
          patch "/api/v1/projects/update_circuit",
                headers: { Authorization: "Token #{token}" },
                params: update_params, as: :json
        end

        it "returns status unprocessable entity" do
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.parsed_body["status"]).to eq("error")
          expect(response.parsed_body["status"]["error"]).not_to be_empty
        end
      end
    end
  end
end
