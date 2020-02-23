# frozen_string_literal: true

require "rails_helper"

describe SimulatorController, type: :request do
  before do
    @user = FactoryBot.create(:user)
    @project = FactoryBot.create(:project, author: @user, name: "Test Name",
     project_access_type: "Public")
  end

  describe "should create empty project"  do
    before do
      sign_in @user
    end

    describe "#create" do
      context "image is empty" do
        it "creates project with default image" do
          expect_any_instance_of(SimulatorHelper).to receive(:sanitize_data)
          expect {
            post "/simulator/create_data", params: { image: "", name: "Test Name" }
          }.to change { Project.count }.by(1)
          expect(response.status).to eq(302)
          created_project = Project.order("created_at").last
          expect(created_project.image_preview.path.split("/")[-1]).to eq("default.png")
        end
      end

      context "there is image data", :skip_windows do
        it "creates project with its own image file" do
          expect {
            post "/simulator/create_data", params: { image:
              "data:image/jpeg;base64,#{Faker::Alphanumeric.alpha(number: 20)}", name: "Test Name" }
          }.to change { Project.count }.by(1)
          created_project = Project.order("created_at").last
          expect(created_project.image_preview.path.split("/")[-1]).to start_with("preview_")
        end
      end
    end

    describe "#update" do
      let(:update_params) {
        {
          id: @project.id,
          name: "Updated Name",
          image: ""
        }
      }

      context "author is signed in" do
        it "updates project" do
          sign_in @user
          expect_any_instance_of(SimulatorHelper).to receive(:sanitize_data)
          post "/simulator/update_data", params: update_params
          @project.reload
          expect(@project.name).to eq("Updated Name")
          expect(response.status).to eq(200)
        end
      end

      context "user other than author is signed in" do
        it "throws project access error" do
          sign_in_random_user
          post "/simulator/update_data", params: update_params
          check_project_access_error(response)
        end
      end
    end

    describe "#embed" do
      context "project is private" do
        before do
          @private = FactoryBot.create(:project, author: @user, project_access_type: "Private")
        end

        it "throws project access error" do
          sign_in_random_user
          get simulator_embed_path(@private)
          check_project_access_error(response)
        end
      end
    end
  end
end
