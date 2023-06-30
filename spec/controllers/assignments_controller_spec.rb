# frozen_string_literal: true

require "rails_helper"

describe AssignmentsController, type: :request do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
    @assignment = FactoryBot.create(:assignment, group: @group)
    @member = FactoryBot.create(:user)
    FactoryBot.create(:group_member, user: @member, group: @group)
  end

  describe "#new" do
    context "when a random user is signed in" do
      it "restricts access" do
        sign_in create(:user)
        get new_group_assignment_path(@group)
        expect(response.body).to include("You are not authorized to do the requested operation")
      end
    end

    context "when a mentor is signed in" do
      it "renders required template" do
        sign_in_group_mentor(@group)
        get new_group_assignment_path(@group)
        expect(response.body).to include("New Assignment")
      end
    end

    context "when primary_mentor is signed in" do
      it "renders required template" do
        sign_in @primary_mentor
        get new_group_assignment_path(@group)
        expect(response.body).to include("New Assignment")
      end
    end
  end

  describe "#show" do
    before do
      sign_in @member
    end

    context "render view" do
      it "shows the requested assignment" do
        get group_assignment_path(@group, @assignment)
        expect(response.status).to eq(200)
        expect(response.body).to include(@assignment.description)
      end
    end

    context "api endpoint" do
      let(:assignment_keys) { %w[created_at deadline description id name updated_at url] }

      it "returns required json response" do
        get group_assignment_path(@group, @assignment), params: { format: :json }
        res = JSON.parse(response.body)
        expect(response.media_type).to eq("application/json")
        expect(res.keys.sort).to eq(assignment_keys)
      end
    end
  end

  describe "#start" do
    before do
      sign_in @member
    end

    context "when assignment is closed or project already exists" do
      before do
        @closed_assignment = create(:assignment, group: @group, status: "closed")
        create(:project, assignment: @assignment, author: @member)
      end

      it "restricts access" do
        get assignment_start_path(@group, @closed_assignment)
        expect(response.body).to include("You are not authorized to do the requested operation")

        get assignment_start_path(@group, @assignment)
        expect(response.body).to include("You are not authorized to do the requested operation")
      end
    end

    it "starts a new project" do
      get assignment_start_path(@group, @assignment)
      expect(response.status).to eq(302)
    end
  end

  describe "#close" do
    context "when random user is signed in" do
      before do
        sign_in @member
      end

      it "restricts access" do
        put close_group_assignment_path(@group, @assignment)
        expect(response.body).to include("You are not authorized to do the requested operation")
      end
    end

    context "when mentor is signed in" do
      before do
        sign_in @primary_mentor
      end

      context "when assignment is open" do
        it "closes the assignment" do
          put close_group_assignment_path(@group, @assignment)
          @assignment.reload
          expect(@assignment.status).to eq("closed")
        end
      end

      context "when assignment is closed" do
        before do
          @assignment.update(status: "closed")
        end

        it "closes the assignment" do
          put close_group_assignment_path(@group, @assignment)
          @assignment.reload
          expect(@assignment.status).to eq("closed")
        end
      end
    end
  end

  describe "#update" do
    let(:update_params) do
      {
        assignment: {
          description: "updated description <br> with line break"
        }
      }
    end
    let(:mentor_update_params) do
      {
        assignment: {
          description: "updated description"
        }
      }
    end

    context "when primary_mentor is signed in" do
      it "updates the assignment" do
        sign_in @primary_mentor
        put group_assignment_path(@group, @assignment), params: update_params
        @assignment.reload
        expect(@assignment.description).to eq("updated description <br> with line break")
      end
    end

    context "when a mentor is signed in" do
      it "updates the assignment" do
        sign_in_group_mentor(@group)
        put group_assignment_path(@group, @assignment), params: mentor_update_params
        @assignment.reload
        expect(@assignment.description).to eq("updated description")
      end
    end

    context "when a random user is signed in" do
      it "returns unauthorized error" do
        sign_in_random_user
        put group_assignment_path(@group, @assignment), params: update_params
        expect(response.body).to eq("You are not authorized to do the requested operation")
      end
    end
  end

  describe "#check_reopening_status" do
    before do
      sign_in @primary_mentor
    end

    context "when the project is forked" do
      before do
        @project = create(:project, author: @member)
        @forked_project = create(:project,
                                 author: @member, forked_project: @project, assignment:
                                  @assignment, project_submission: true)
      end

      it "adds old project as assignment submission" do
        put group_assignment_path(@group, @assignment), params: { assignment:
          { description: "new description" } }
        @project.reload
        expect(Project.find_by(id: @forked_project.id)).to be_nil
        expect(@project.assignment_id).to eq(@forked_project.assignment_id)
      end
    end

    context "when no forked project exists" do
      before do
        @project = create(:project,
                          author: @member, assignment: @assignment, project_submission: true)
      end

      it "sets project submission to false" do
        put group_assignment_path(@group, @assignment), params: { assignment:
          { description: "new description" } }
        @project.reload
        expect(@project.project_submission).to be(false)
      end
    end
  end

  describe "#reopen" do
    before do
      @closed_assignment = FactoryBot.create(:assignment, group: @group, status: "closed")
    end

    context "when primary_mentor is signed in" do
      it "changes status to open" do
        sign_in @primary_mentor
        expect(@closed_assignment.status).to eq("closed")
        get reopen_group_assignment_path(@group, @closed_assignment)
        @closed_assignment.reload
        expect(@closed_assignment.status).to eq("open")
      end
    end

    context "when a mentor is signed in" do
      it "changes status to open" do
        sign_in_group_mentor(@group)
        expect(@closed_assignment.status).to eq("closed")
        get reopen_group_assignment_path(@group, @closed_assignment)
        @closed_assignment.reload
        expect(@closed_assignment.status).to eq("open")
      end
    end

    context "when a random user is signed in" do
      it "throws not authorized error" do
        sign_in_random_user
        expect(@closed_assignment.status).to eq("closed")
        get reopen_group_assignment_path(@group, @closed_assignment)
        expect(response.body).to eq("You are not authorized to do the requested operation")
        expect(@closed_assignment.status).to eq("closed")
      end
    end
  end

  describe "#create" do
    context "when primary_mentor is logged in" do
      it "creates a new assignment" do
        sign_in @primary_mentor
        expect do
          post group_assignments_path(@group), params: { assignment:
            { description: "group assignment", name: "Test Name" } }
        end.to change(Assignment, :count).by(1)
      end

      it "sends notifications to group members" do
        sign_in @primary_mentor
        post group_assignments_path(@group), params: { assignment:
          { description: "group assignment", name: "Test Name" } }
        expect(@member.noticed_notifications.count).to eq(1)
      end
    end

    context "when a mentor is logged in" do
      it "creates a new assignment" do
        sign_in_group_mentor(@group)
        expect do
          post group_assignments_path(@group), params: { assignment:
            { description: "group assignment", name: "Test Name" } }
        end.to change(Assignment, :count).by(1)
      end
    end

    context "when a random user is logged in" do
      it "does not create assignment" do
        sign_in create(:user)
        expect do
          post group_assignments_path(@assignment)
        end.not_to change(Assignment, :count)
      end
    end
  end
end
