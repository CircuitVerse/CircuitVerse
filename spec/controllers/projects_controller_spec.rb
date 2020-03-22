# frozen_string_literal: true

require "rails_helper"

describe ProjectsController, type: :request do
  before do
    @author = FactoryBot.create(:user)
  end

  describe "#get_projects" do
    before do
      @tag = FactoryBot.create(:tag)
      @projects = [ FactoryBot.create(:project, author: @author),
      FactoryBot.create(:project, author: @author) ]
      @projects.each { |project| FactoryBot.create(:tagging, project: project, tag: @tag) }
    end

    it "gets project with mentioned tags" do
      get tag_path(@tag.name)
      @projects.each do |project|
        expect(response.body).to include(project.name)
      end
    end
  end

  describe "#show" do
    context "project is public" do
      before do
        @project = FactoryBot.create(:project, author: @author, project_access_type: "Public")
      end

      it "shows project and increases views" do
        expect {
          get user_project_path(@author, @project)
          @project.reload
        }.to change { @project.view }.by(1)

        expect(response.body).to include(@project.name)
      end
    end

    context "project is not public" do
      before do
        @project = FactoryBot.create(:project, author: @author, project_access_type: "Private")
      end

      it "throws project access error" do
        sign_in_random_user
        get user_project_path(@author, @project)
        check_project_access_error(response)
      end
    end
  end

  describe "#change_stars" do
    before do
      @user = sign_in_random_user
      @project = FactoryBot.create(:project, author: @author)
    end

    context "user has not already starred" do
      it "creates a star" do
        expect {
          get change_stars_path(@project), xhr: true
        }.to change { Star.count }.by(1)
      end
    end

    context "user has already starred" do
      before do
        FactoryBot.create(:star, project: @project, user: @user)
      end

      it "deletes the star" do
        expect {
          get change_stars_path(@project), xhr: true
        }.to change { Star.count }.by(-1)
      end
    end
  end

  describe "#create_fork" do
    before do
      @user = sign_in_random_user
      @project = FactoryBot.create(:project, author: @author, project_access_type: "Public")
    end

    context "project is not an assignment" do
      it "creates a fork" do
        expect {
          get create_fork_project_path(@project)
          @user.reload
        }.to change { @user.projects.count }.by(1)
        expect(@user.projects.order("created_at").last.forked_project_id).to eq(@project.id)
      end
    end

    context "project is an assignment" do
      before do
        group = FactoryBot.create(:group, mentor: FactoryBot.create(:user))
        assignment = FactoryBot.create(:assignment, group: group)
        @assignment_project = FactoryBot.create(:project, author: @author, assignment: assignment)
      end

      it "throws error" do
        get create_fork_project_path(@assignment_project)
        check_project_access_error(response)
      end
    end

    describe "#create" do
      before do
        @user = sign_in_random_user
      end

      let(:create_params) {
        {
          project: {
            name: "Test Project",
            project_access_type: "Public",
          }
        }
      }

      it "creates project" do
        expect {
          post "/users/#{@user.id}/projects", params: create_params
        }.to change { Project.count }.by(1)

        project = Project.all.order("created_at").last
        expect(project.name).to eq("Test Project")
        expect(project.project_access_type).to eq("Public")
      end
    end

    describe "#update" do
      let(:update_params) {
        {
          project: {
            name: "Updated Name"
          }
        }
      }

      before do
        @project = FactoryBot.create(:project, author: @author, name: "Test Name")
      end

      context "author is signed in" do
        before do
          sign_in @author
        end

        it "updates project" do
          put user_project_path(@author, @project), params: update_params
          @project.reload
          expect(@project.name).to eq("Updated Name")
        end
      end

      context "user other than author is singed in" do
        it "throws project access error" do
          sign_in_random_user
          put user_project_path(@author, @project), params: update_params
          check_project_access_error(response)
        end
      end
    end

    describe "#destroy" do
      before do
        @project = FactoryBot.create(:project, author: @author)
      end

      context "author is signed in" do
        it "destroys project" do
          sign_in @author
          expect {
            delete user_project_path(@author, @project)
          }.to change { Project.count }.by(-1)
        end
      end

      context "user other that author is signed in" do
        it "throws project access error" do
          sign_in_random_user
          delete user_project_path(@author, @project)
          check_project_access_error(response)
        end
      end
    end
  end
end
