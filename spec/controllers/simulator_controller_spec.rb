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
      context "image is empty" do
        it "creates project with default image" do
          expect_any_instance_of(SimulatorHelper).to receive(:sanitize_data)
          expect do
            post "/simulator/create_data", params: { image: "", name: "Test Name" }
          end.to change(Project, :count).by(1)
          expect(response.status).to eq(302)
          created_project = Project.order("created_at").last
          expect(created_project.image_preview.path.split("/")[-1]).to eq("default.png")
        end
      end

      context "there is image data", :skip_windows do
        it "creates project with its own image file" do
          expect do
            post "/simulator/create_data", params: { image:
              "data:image/jpeg;base64,#{Faker::Alphanumeric.alpha(number: 20)}", name: "Test Name" }
          end.to change(Project, :count).by(1)
          created_project = Project.order("created_at").last
          expect(created_project.image_preview.path.split("/")[-1]).to start_with("preview_")
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

        it "redirects to default simulatorvue path if path is root" do
          expect(response).to redirect_to default_simulatorvue_path
        end
      end

      context "when vuesim is enabled for user and user tries to edit a circuit" do
        before do
          allow(Flipper).to receive(:enabled?).with(:vuesim, @user).and_return(true)
          get simulator_path(@project)
        end

        it "redirects to the simulatorvue path with the given path" do
          get simulator_edit_path(@project)
          expect(response).to redirect_to simulatorvue_path(path: "edit/#{@project.name.parameterize}")
        end
      end

      context "when vuesim is not enabled for user" do
        before do
          allow(Flipper).to receive(:enabled?).with(:vuesim, @user).and_return(false)
          get simulator_path(@project)
        end

        it "does not redirect to simulatorvue" do
          expect(response).not_to redirect_to default_simulatorvue_path
        end
      end
    end
  end
end
