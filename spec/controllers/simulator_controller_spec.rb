# frozen_string_literal: true

require "rails_helper"

describe SimulatorController, type: :request do
  before do
    @user = FactoryBot.create(:user)
    @project = FactoryBot.create(:project, author: @user, name: "Test Name",
                                           project_access_type: "Public")
  end

  describe "should create empty project" do
    before do
      sign_in @user
    end

    describe "#create" do
      describe "when Flipper is enabled" do
        context "image is empty" do
          it "creates project with default image" do
            expect_any_instance_of(SimulatorHelper).to receive(:sanitize_data)
            expect do
              post "/simulator/create_data", params: { image: "", name: "Test Name" }
            end.to change(Project, :count).by(1)
            expect(response.status).to eq(302)
            created_project = Project.order(:created_at).last
            expect(created_project.circuit_preview.blob).to be_nil
            expect(created_project.image_preview.file.filename).to eq("default.png")
          end
        end

        context "there is image data", :skip_windows do
          it "creates project with its own image file" do
            expect do
              post "/simulator/create_data", params: { image:
                "data:image/jpeg;base64,#{Faker::Alphanumeric.alpha(number: 20)}", name: "Test Name" }
            end.to change(Project, :count).by(1)
            created_project = Project.order(:created_at).last
            expect(created_project.circuit_preview.blob.filename.to_s).to start_with("preview_")
            expect(created_project.image_preview.file.filename).to start_with("preview_")
          end
        end
      end

      describe "when Flipper is disabled" do
        Flipper.disable(:active_storage_s3)
        context "image is empty" do
          it "creates project with default image" do
            expect_any_instance_of(SimulatorHelper).to receive(:sanitize_data)
            expect do
              post "/simulator/create_data", params: { image: "", name: "Test Name" }
            end.to change(Project, :count).by(1)
            expect(response.status).to eq(302)
            created_project = Project.order(:created_at).last
            expect(created_project.circuit_preview.blob).to be_nil
            expect(created_project.image_preview.file.filename).to eq("default.png")
          end
        end

        context "there is image data", :skip_windows do
          it "creates project with its own image file" do
            expect do
              post "/simulator/create_data", params: { image:
                "data:image/jpeg;base64,#{Faker::Alphanumeric.alpha(number: 20)}", name: "Test Name" }
            end.to change(Project, :count).by(1)
            created_project = Project.order(:created_at).last
            expect(created_project.circuit_preview.blob.filename.to_s).to start_with("preview_")
            expect(created_project.image_preview.file.filename).to start_with("preview_")
          end
        end
      end
    end

    describe "#update" do
      let(:update_params) do
        {
          id: @project.id,
          name: "Updated Name",
          image: ""
        }
      end

      describe "when Flipper is enabled" do
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
            expect(response.status).to eq(403)
          end
        end
      end

      describe "when Flipper is disabled" do
        Flipper.disable(:active_storage_s3)
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
            expect(response.status).to eq(403)
          end
        end
      end
    end

    describe "#edit" do
      context "when author is signed in" do
        it "allows access to edit page" do
          sign_in @user
          get simulator_edit_path(@project)
          expect(response).to have_http_status(:success)
        end
      end

      context "when collaborator is signed in" do
        it "allows access to edit page" do
          @collaborator = FactoryBot.create(:user)
          FactoryBot.create(:collaboration, project: @project, user: @collaborator)
          sign_in @collaborator
          get simulator_edit_path(@project)
          expect(response).to have_http_status(:success)
        end
      end

      context "when user other than author is signed in" do
        it "denies access to edit page" do
          sign_in_random_user
          get simulator_edit_path(@project)
          expect(response.status).to eq(403)
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

    describe "#redirect_to_vue_simulator_if_enabled" do
      context "when vuesim is enabled for user and user opens black simualtor" do
        before do
          allow(Flipper).to receive(:enabled?).with(:vuesim, @user).and_return(true)
          get simulator_new_path
        end

        it "renders the vue simulator" do
          expect(response.status).to eq(200)
          expect(response.body).to include("simulator-v0.js")
        end
      end

      context "when vuesim is enabled for user and user tries to edit a circuit" do
        before do
          allow(Flipper).to receive(:enabled?).with(:vuesim, @user).and_return(true)
          get simulator_edit_path(@project)
        end

        it "renders the vue simulator" do
          expect(response.status).to eq(200)
          expect(response.body).to include("simulator-v0.js")
        end
      end

      context "when vuesim is not enabled for user" do
        before do
          allow(Flipper).to receive(:enabled?).with(:vuesim, @user).and_return(false)
          get simulator_path(@project)
        end

        it "does not render the vue simulator" do
          expect(response.body).not_to include("simulator-v0.js")
        end
      end
    end
  end
end
