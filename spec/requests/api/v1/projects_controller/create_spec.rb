# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#create", type: :request do
  describe "POST #create" do
    let!(:user) { FactoryBot.create(:user) }

    context "when unauthenticated user creates project" do
      it "returns status unauthorized" do
        expect do
          post "/api/v1/projects", params: { image: "", name: "Test Name" }, as: :json
        end.not_to change(Project, :count)

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_jsonapi_errors
      end
    end

    context "when authenticated user creates project" do
      it "returns status created" do
        expect do
          token = get_auth_token(user)
          post "/api/v1/projects",
               headers: { Authorization: "Token #{token}" },
               params: { image: "", name: "Test Name" }, as: :json
        end.to change(Project, :count).by(1)

        expect(response).to have_http_status(:created)
        parsed_response = response.parsed_body
        expect(parsed_response["project"]).to be_present
        expect(parsed_response["project"]["name"]).to eq("Test Name")
        expect(parsed_response["project"]["project_access_type"]).to eq("Public")
      end
    end

    context "when image is empty" do
      it "creates project with default image" do
        expect_any_instance_of(SimulatorHelper).to receive(:sanitize_data)
        expect do
          token = get_auth_token(user)
          post "/api/v1/projects",
               headers: { Authorization: "Token #{token}" },
               params: { image: "", name: "Test Name" }, as: :json
        end.to change(Project, :count).by(1)

        expect(response).to have_http_status(:created)
        created_project = Project.order(:created_at).last
        expect(created_project.image_preview.path.split("/")[-1]).to eq("default.png")
        expect(created_project.circuit_preview).not_to be_attached
      end
    end

    context "when there is image data", :skip_windows do
      it "creates project with its own image file and attaches a circuit preview" do
        expect do
          token = get_auth_token(user)
          post "/api/v1/projects",
               headers: { Authorization: "Token #{token}" },
               params: { image: "data:image/jpeg;base64,#{Faker::Alphanumeric.alpha(number: 20)}", name: "Test Name" },
               as: :json
        end.to change(Project, :count).by(1)

        created_project = Project.order(:created_at).last
        expect(created_project.image_preview.path.split("/")[-1]).to start_with("preview_")
        expect(created_project.circuit_preview).to be_attached
        expect(created_project.circuit_preview.filename.to_s).to start_with("preview_")
        expect(created_project.circuit_preview.content_type).to eq("image/jpeg")
      end
    end

    context "when there is error in saving project" do
      it "returns status unprocessable_entity" do
        expect do
          token = get_auth_token(user)
          allow_any_instance_of(Project).to receive(:save).and_return(false)
          post "/api/v1/projects",
               headers: { Authorization: "Token #{token}" },
               params: { image: "", name: "Test Name" }, as: :json
        end.not_to change(Project, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["status"]).to eq("error")
        expect(response.parsed_body["status"]["error"]).not_to be_empty
      end
    end
  end
end
