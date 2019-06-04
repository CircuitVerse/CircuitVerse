# frozen_string_literal: true

require "rails_helper"

describe GradesController, type: :request do
  before do
    @mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, mentor: @mentor)
    @assignment = FactoryBot.create(:assignment, group: @group, grading_scale: :letter)
    @assignment_project = FactoryBot.create(:project, assignment: @assignment,
      author: FactoryBot.create(:user))
  end

  describe "#create" do
    let(:create_params) {
      {
        grade: {
          project_id: @assignment_project.id,
          assignment_id: @assignment.id,
          user_id: @mentor.id,
          grade: "A"
        },
        format: :json
      }
    }

    context "mentor is singed in" do
      before do
        sign_in @mentor
      end

      context "grade is valid" do
        it "creates grade" do
          expect {
            post grades_path, params: create_params
          }.to change { Grade.count }.by(1)
          expect(JSON.parse(response.body).keys.sort).to eq(%w[assignment_id grade id project_id])
          expect(response.content_type).to eq("application/json")
        end
      end

      context "grade is invalid" do
        it "throws bad request error" do
          invalid_params = create_params
          create_params[:grade][:grade] = "90"
          post grades_path, params: invalid_params
          expect(response.status).to eq(400)
          expect(JSON.parse(response.body)["error"]).to eq("Grade is invalid")
        end
      end
    end

    context "some other user is signed in" do
      it "gives unauthorized error" do
        sign_in FactoryBot.create(:user)
        post grades_path, params: create_params
        expect(response.body).to eq("You are not authorized to do the requested operation")
      end
    end
  end

  describe "#destroy" do
    let(:destroy_params) {
      {
        grade: {
          project_id: @assignment_project.id
        }
      }
    }

    before do
      @grade = FactoryBot.create(:grade, project: @assignment_project, grader: @mentor,
        grade: "A", assignment: @assignment)
    end

    context "mentor is logged in" do
      it "destroys user" do
        sign_in @mentor
        expect {
          delete grades_path, params: destroy_params
        }.to change { Grade.count }.by(-1)
      end
    end

    context "user other than mentor is logged in" do
      it "throws unauthorized error" do
        sign_in FactoryBot.create(:user)
        expect {
          delete grades_path, params: destroy_params
        }.to_not change { Grade.count }
        expect(response.body).to eq("You are not authorized to do the requested operation")
      end
    end
  end
end
