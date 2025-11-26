# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignmentsController, type: :request do
  let(:user) { create(:user) }
  let(:primary_mentor) { create(:user) }
  let(:group) { create(:group, primary_mentor: primary_mentor) }
  let(:assignment) { create(:assignment, group: group) }

  before do
    sign_in user
    group.group_members.create!(user: user)
  end

  describe "GET #start" do
    context "when starting an assignment for the first time" do
      it "creates a new project" do
        expect do
          get assignment_start_path(group, assignment)
        end.to change(Project, :count).by(1)
      end

      it "assigns the project to the current user" do
        get assignment_start_path(group, assignment)
        project = Project.last
        expect(project.author).to eq(user)
      end

      it "links the project to the assignment" do
        get assignment_start_path(group, assignment)
        project = Project.last
        expect(project.assignment).to eq(assignment)
      end

      it "sets the project as private" do
        get assignment_start_path(group, assignment)
        project = Project.last
        expect(project.project_access_type).to eq("Private")
      end

      it "redirects to the project page" do
        get assignment_start_path(group, assignment)
        project = Project.last
        expect(response).to redirect_to(user_project_path(user, project))
      end
    end

    context "when project already exists for the assignment" do
      let!(:existing_project) do
        create(:project,
               author: user,
               assignment: assignment,
               name: "#{user.name}/#{assignment.name}")
      end

      it "does not create a new project" do
        expect do
          get assignment_start_path(group, assignment)
        end.not_to change(Project, :count)
      end

      it "redirects to the existing project" do
        get assignment_start_path(group, assignment)
        expect(response).to redirect_to(user_project_path(user, existing_project))
      end

      it "shows a notice about continuing the existing project" do
        get assignment_start_path(group, assignment)
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
        get assignment_start_path(group, assignment)

        project = Project.last
        expect(response).to redirect_to(user_project_path(user, project))
        expect(project.assignment).to eq(assignment)
        expect(flash[:notice]).to be_present
      end
    end

    context "authorization" do
      it "requires authentication" do
        sign_out user
        get assignment_start_path(group, assignment)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "requires group membership" do
        other_user = create(:user)
        sign_in other_user
        get assignment_start_path(group, assignment)
        expect(response.body).to include("You are not authorized")
      end
    end
  end
end
