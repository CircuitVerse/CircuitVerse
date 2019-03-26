# frozen_string_literal: true

require "rails_helper"

describe AssignmentsController, type: :request do
  before do
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @mentor)
    @assignment = FactoryBot.create(:assignment, group: @group)
    @member = FactoryBot.create(:user)
    FactoryBot.create(:group_member, user: @member, group: @group)
  end

  describe "#new" do
    context "user is not mentor" do
      it "restrics access" do
        sign_in FactoryBot.create(:user)
        get new_group_assignment_path(@group)
        expect(response.body).to include("You are not authorized to do the requested operation")
      end
    end

    context "user is mentor" do
      it "renders required template" do
        sign_in @mentor
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
        expect(response.content_type).to eq("application/json")
        expect(res.keys.sort).to eq(assignment_keys)
      end
    end
  end

  describe "#start" do
    before do
      sign_in @member
    end

    context "assignment is closed or project already exists" do
      before do
        @closed_assignment = FactoryBot.create(:assignment, group: @group, status: "closed")
        FactoryBot.create(:project, assignment: @assignment, author: @member)
      end

      it "restrics access" do
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
end
