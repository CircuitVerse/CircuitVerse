# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#create", type: :request do
  describe "POST #create" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, author: user, name: "Test Name", project_access_type: "Public") }

    context "when image is empty" do
      it "creates project with default image" do
        expect_any_instance_of(SimulatorHelper).to receive(:sanitize_data)
        expect do
          token = get_auth_token(user)
          post "/api/v1/projects",
              headers: { Authorization: "Token #{token}" }, as: :json,
              params: { image: "", name: "Test Name" }
        end.to change(Project, :count).by(1)

        expect(response).to have_http_status(:created)
        created_project = Project.order("created_at").last
        expect(created_project.image_preview.path.split("/")[-1]).to eq("default.png")
      end
    end

    context "when there is image data", :skip_windows do
      it "creates project with its own image file" do
        expect do
          token = get_auth_token(user)
          post "/api/v1/projects",
              headers: { Authorization: "Token #{token}" }, as: :json,
              params: { image: "data:image/jpeg;base64,#{Faker::Alphanumeric.alpha(number: 20)}", name: "Test Name" }
        end.to change(Project, :count).by(1)

        created_project = Project.order("created_at").last
        expect(created_project.image_preview.path.split("/")[-1]).to start_with("preview_")
      end
    end
  end
end
