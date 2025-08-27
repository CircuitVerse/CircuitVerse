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
      it "creates the project and returns status created" do
        image_data = "data:image/jpeg;base64,#{Faker::Alphanumeric.alpha(number: 20)}"
        
        allow_any_instance_of(Api::V1::ProjectsController).to receive(:parse_image_data_url).with(image_data).and_return(StringIO.new)
        allow_any_instance_of(Api::V1::ProjectsController).to receive(:attach_circuit_preview).and_return(true)

        expect do
          token = get_auth_token(user)
          post "/api/v1/projects",
               headers: { Authorization: "Token #{token}" },
               params: { image: image_data, name: "Test Name" }, as: :json
        end.to change(Project, :count).by(1)

        expect(response).to have_http_status(:created)
        parsed_response = response.parsed_body
        expect(parsed_response["project"]).to be_present
        expect(parsed_response["project"]["name"]).to eq("Test Name")
      end
    end

    context "when image is empty" do
      it "creates project with default image" do
        allow_any_instance_of(SimulatorHelper).to receive(:sanitize_data)
        allow_any_instance_of(Api::V1::ProjectsController).to receive(:parse_image_data_url).and_return(StringIO.new)
        allow_any_instance_of(Api::V1::ProjectsController).to receive(:attach_circuit_preview).and_return(true)

        expect do
          token = get_auth_token(user)
          post "/api/v1/projects",
               headers: { Authorization: "Token #{token}" },
               params: { image: "", name: "Test Name" }, as: :json
        end.to change(Project, :count).by(1)

        expect(response).to have_http_status(:created)
        created_project = Project.order("created_at").last
        expect(created_project.image_preview.path.split("/")[-1]).to eq("default.png")
      end
    end

    context "when there is image data", :skip_windows do
      it "creates project with its own image file" do
        image_data = "data:image/jpeg;base64,#{Faker::Alphanumeric.alpha(number: 20)}"
        
        allow_any_instance_of(Api::V1::ProjectsController).to receive(:parse_image_data_url).with(image_data).and_return(StringIO.new)
        allow_any_instance_of(Api::V1::ProjectsController).to receive(:attach_circuit_preview).and_return(true)

        expect do
          token = get_auth_token(user)
          post "/api/v1/projects",
               headers: { Authorization: "Token #{token}" },
               params: { image: image_data, name: "Test Name" }, as: :json
        end.to change(Project, :count).by(1)

        created_project = Project.order("created_at").last
        expect(created_project.image_preview.path.split("/")[-1]).to start_with("preview_")
      end
    end

    context "when there is an error in saving the project" do
      it "returns status unprocessable_entity" do
        allow_any_instance_of(Api::V1::ProjectsController).to receive(:parse_image_data_url).and_return(StringIO.new)
        allow_any_instance_of(Api::V1::ProjectsController).to receive(:attach_circuit_preview).and_return(true)
    
        # Force the save to fail
        allow_any_instance_of(Project).to receive(:save).and_return(false)
        
        # Optionally, ensure there are errors on the project
        allow_any_instance_of(Project).to receive(:errors).and_return(ActiveModel::Errors.new(Project.new).tap { |e| e.add(:base, "Simulated save failure") })
    
        expect do
          token = get_auth_token(user)
          post "/api/v1/projects",
               headers: { Authorization: "Token #{token}" },
               params: { image: "", name: "Test Name" }, as: :json
        end.not_to change(Project, :count)
    
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).not_to be_empty
      end
    end
    

    context "when parse_image_data_url raises an error" do
      it "returns status unprocessable_entity" do
        allow_any_instance_of(Api::V1::ProjectsController).to receive(:parse_image_data_url).and_raise(StandardError.new("Parsing error"))

        expect do
          token = get_auth_token(user)
          post "/api/v1/projects",
               headers: { Authorization: "Token #{token}" },
               params: { image: "data:image/jpeg;base64,#{Faker::Alphanumeric.alpha(number: 20)}", name: "Test Name" },
               as: :json
        end.not_to change(Project, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["status"]).to eq("error")
        expect(response.parsed_body["errors"]).to include("Parsing error")
      end
    end

    context "when attach_circuit_preview raises an error" do
      it "returns status unprocessable_entity" do
        allow_any_instance_of(Api::V1::ProjectsController).to receive(:parse_image_data_url).and_return(StringIO.new)
        allow_any_instance_of(Api::V1::ProjectsController).to receive(:attach_circuit_preview).and_raise(StandardError.new("Attachment error"))

        expect do
          token = get_auth_token(user)
          post "/api/v1/projects",
               headers: { Authorization: "Token #{token}" },
               params: { image: "data:image/jpeg;base64,#{Faker::Alphanumeric.alpha(number: 20)}", name: "Test Name" },
               as: :json
        end.not_to change(Project, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["status"]).to eq("error")
        expect(response.parsed_body["errors"]).to include("Attachment error")
      end
    end
  end
end
