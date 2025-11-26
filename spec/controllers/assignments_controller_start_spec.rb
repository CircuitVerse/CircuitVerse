# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignmentsController, type: :controller do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:assignment) { create(:assignment, group: group) }

  before do
    sign_in user
    group.group_members.create!(user: user)
  end

  describe "POST #start" do
    context "when starting an assignment for the first time" do
      it "creates a new project" do
        expect do
          post :start, params: { group_id: group.id, id: assignment.id }
        end.to change(Project, :count).by(1)
      end

      it "assigns the project to the current user" do
        post :start, params: { group_id: group.id, id: assignment.id }
        expect(assigns(:project).author).to eq(user)
      end

      it "links the project to the assignment" do
        post :start, params: { group_id: group.id, id: assignment.id }
        expect(assigns(:project).assignment).to eq(assignment)
      end

      it "sets the project as private" do
        post :start, params: { group_id: group.id, id: assignment.id }
        expect(assigns(:project).project_access_type).to eq("Private")
      end

      it "redirects to the project page" do
        post :start, params: { group_id: group.id, id: assignment.id }
        project = assigns(:project)
        expect(response).to redirect_to(user_project_path(user, project))
      end
    end

    context "when starting an assignment that already has a project" do
      let!(:existing_project) do
        create(:project,
               author: user,
               assignment: assignment,
               name: "#{user.name}/#{assignment.name}")
      end

      it "does not create a new project" do
        expect do
          post :start, params: { group_id: group.id, id: assignment.id }
        end.not_to change(Project, :count)
      end

      it "redirects to the existing project" do
        post :start, params: { group_id: group.id, id: assignment.id }
        expect(response).to redirect_to(user_project_path(user, existing_project))
      end

      it "shows a notice about continuing the existing project" do
        post :start, params: { group_id: group.id, id: assignment.id }
        expect(flash[:notice]).to match(/existing assignment project/i)
      end
    end

    context "when project already exists for the assignment" do
      before do
        # Create project first to simulate what would happen in a race condition
        create(:project, author: user, assignment: assignment)
      end

      it "finds and redirects to the existing project" do
        expect do
          post :start, params: { group_id: group.id, id: assignment.id }
        end.not_to change(Project, :count)

        expect(response).to redirect_to(user_project_path(user, Project.last))
        expect(flash[:notice]).to match(/existing assignment project/i)
      end
    end

    context "when slug would conflict with existing project" do
      before do
        # Create a project with same name but NO assignment (different use case)
        create(:project,
               author: user,
               name: "#{user.name}/#{assignment.name}")
      end

      it "creates a new project with assignment and redirects successfully" do
        post :start, params: { group_id: group.id, id: assignment.id }

        expect(response).to redirect_to(user_project_path(user, assigns(:project)))
        expect(assigns(:project).assignment).to eq(assignment)
        expect(flash[:notice]).to be_present
      end
    end

    context "authorization" do
      it "requires authentication" do
        sign_out user
        post :start, params: { group_id: group.id, id: assignment.id }
        expect(response).to redirect_to(new_user_session_path)
      end

      it "authorizes the assignment access" do
        allow(controller).to receive(:authorize).and_call_original
        post :start, params: { group_id: group.id, id: assignment.id }
        expect(controller).to have_received(:authorize).with(assignment)
      end
    end
  end
end
