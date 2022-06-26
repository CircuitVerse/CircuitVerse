# frozen_string_literal: true

require "rails_helper"

describe GradesController, type: :request do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
    @assignment = FactoryBot.create(:assignment, group: @group, grading_scale: :letter)
    @assignment_project = FactoryBot.create(:project, assignment: @assignment,
                                                      author: FactoryBot.create(:user))
  end

  describe "#create" do
    let(:create_params) do
      {
        grade: {
          project_id: @assignment_project.id,
          assignment_id: @assignment.id,
          user_id: @primary_mentor.id,
          grade: "A",
          remarks: "Some remarks"
        },
        format: :json
      }
    end

    context "when primary_mentor is singed in" do
      before do
        sign_in @primary_mentor
      end

      context "when grade is valid" do
        it "creates grade" do
          expect do
            post grades_path, params: create_params
          end.to change(Grade, :count).by(1)
          expect(JSON.parse(response.body).keys.sort).to eq(%w[assignment_id grade id project_id
                                                               remarks])
          expect(response.content_type).to eq("application/json; charset=utf-8")
        end
      end

      context "when grade is invalid" do
        it "throws bad request error" do
          invalid_params = create_params
          create_params[:grade][:grade] = "90"
          post grades_path, params: invalid_params
          expect(response.status).to eq(400)
          expect(JSON.parse(response.body)["error"]).to eq("Grade is invalid")
        end
      end
    end

    context "when a mentor is singed in" do
      before do
        sign_in_group_mentor(@group)
      end

      context "when grade is valid" do
        it "creates grade" do
          expect do
            post grades_path, params: create_params
          end.to change(Grade, :count).by(1)
          expect(JSON.parse(response.body).keys.sort).to eq(%w[assignment_id grade id project_id
                                                               remarks])
          expect(response.content_type).to eq("application/json; charset=utf-8")
        end
      end

      context "when grade is invalid" do
        it "throws bad request error" do
          invalid_params = create_params
          create_params[:grade][:grade] = "90"
          post grades_path, params: invalid_params
          expect(response.status).to eq(400)
          expect(JSON.parse(response.body)["error"]).to eq("Grade is invalid")
        end
      end
    end

    context "when some other user is signed in" do
      it "gives unauthorized error" do
        sign_in FactoryBot.create(:user)
        post grades_path, params: create_params
        expect(response.body).to eq("You are not authorized to do the requested operation")
      end
    end
  end

  describe "#destroy" do
    let(:destroy_params) do
      {
        grade: {
          project_id: @assignment_project.id,
          assignment_id: @assignment.id
        }
      }
    end

    before do
      @grade = FactoryBot.create(:grade, project: @assignment_project, grader: @primary_mentor,
                                         grade: "A", assignment: @assignment)
    end

    context "when primary_mentor is logged in" do
      before do
        sign_in @primary_mentor
      end

      context "when grades have not been finalized" do
        it "destroys grade" do
          expect do
            delete grades_path, params: destroy_params
          end.to change(Grade, :count).by(-1)
        end
      end
    end

    context "when a mentor is logged in" do
      before do
        sign_in_group_mentor(@group)
      end

      context "when grades have not been finalized" do
        it "destroys grade" do
          expect do
            delete grades_path, params: destroy_params
          end.to change(Grade, :count).by(-1)
        end
      end
    end

    context "when a user other than primary_mentor/mentor is logged in" do
      it "throws unauthorized error" do
        sign_in FactoryBot.create(:user)
        expect do
          delete grades_path, params: destroy_params
        end.not_to change(Grade, :count)
        expect(response.body).to eq("You are not authorized to do the requested operation")
      end
    end
  end

  describe "#to_csv" do
    before do
      FactoryBot.create(:group_member, user: @assignment_project.author, group: @group)
      @grade = FactoryBot.create(:grade, project: @assignment_project, grader: @primary_mentor,
                                         grade: "A", assignment: @assignment, remarks: "remarks")
    end

    context "when signed user is primary_mentor" do
      it "creates csv file for grades" do
        sign_in @primary_mentor
        get grades_to_csv_path(@assignment, format: :csv)
        expect(response.body).to include("#{@assignment_project.author.email}," \
                                         "#{@assignment_project.author.name},#{@grade.grade},#{@grade.remarks}")
      end
    end
  end
end
