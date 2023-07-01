# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ProjectsController, "#update_circuit", type: :request do
  describe "update circuit" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:random_user) { FactoryBot.create(:user) }
    let!(:project) { FactoryBot.create(:project, author: user, name: "Test Name", project_access_type: "Public") }
  end

  describe "should create empty project" do
    describe "#create" do
      context "image is empty" do
        it "creates project with default image" do
          expect_any_instance_of(SimulatorHelper).to receive(:sanitize_data)
          expect do
            token = get_auth_token(user)
            post "/api/v1/projects",
                headers: { Authorization: "Token #{token}" }, as: :json,
                params: { image: "", name: "Test Name" }
          end.to change(Project, :count).by(1)
          expect(response.status).to eq(302)
          created_project = Project.order("created_at").last
          expect(created_project.image_preview.path.split("/")[-1]).to eq("default.png")
        end
      end

      context "there is image data", :skip_windows do
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

    describe "#update_circuit" do
      let(:update_params) do
        {
          id: @project.id,
          name: "Updated Name",
          image: ""
        }
      end

      context "author is signed in" do
        it "updates project" do
          token = get_auth_token(user)
          expect_any_instance_of(SimulatorHelper).to receive(:sanitize_data)
          patch "/api/v1/projects/update_circuit",
              headers: { Authorization: "Token #{token}" }, as: :json,
              params: update_params
          @project.reload
          expect(@project.name).to eq("Updated Name")
          expect(response.status).to eq(200)
        end
      end

      context "user other than author is signed in" do
        it "throws project access error" do
          token = get_auth_token(random_user)
          patch "/api/v1/projects/update_circuit",
              headers: { Authorization: "Token #{token}" }, as: :json,
              params: update_params
          expect(response.status).to eq(403)
        end
      end
    end
  end
end
