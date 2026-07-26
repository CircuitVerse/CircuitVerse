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
          expect(response.parsed_body.keys.sort).to eq(%w[assignment_id grade id project_id
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
          expect(response.parsed_body["error"]).to eq("Grade is invalid")
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
          expect(response.parsed_body.keys.sort).to eq(%w[assignment_id grade id project_id
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
          expect(response.parsed_body["error"]).to eq("Grade is invalid")
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

  describe "LTI 1.1 grade passback" do
    let(:consumer_key) { "passback-consumer-key" }
    let(:outcome_url)  { "https://lms.example.test/outcomes" }

    before do
      Flipper.enable(:lms_integration)
      @lti_assignment = FactoryBot.create(:assignment, group: @group, grading_scale: :percent,
                                                       lti_consumer_key: consumer_key,
                                                       lti_shared_secret: "secret")
      @lti_project = FactoryBot.create(:project, assignment: @lti_assignment,
                                                 author: FactoryBot.create(:user),
                                                 lis_result_sourced_id: "result-123")
      sign_in @primary_mentor
    end

    after { Flipper.disable(:lms_integration) }

    def prime_lti_session(key, secret = "secret")
      get "/" # capture the host request specs run against
      launch_params = {
        "launch_url" => "http://#{request.host}:#{request.port}/lti/launch",
        "lti_version" => "LTI-1p0",
        "lti_message_type" => "basic-lti-launch-request",
        "resource_link_id" => "res-link-1",
        "lis_person_contact_email_primary" => @primary_mentor.email,
        "lis_outcome_service_url" => outcome_url
      }
      consumer = IMS::LTI::ToolConsumer.new(key, secret, launch_params)
      allow(consumer).to receive(:to_params).and_return(launch_params)
      post "/lti/launch", params: consumer.generate_launch_data,
                          headers: { "Content-Type": "application/x-www-form-urlencoded" }
    end

    def lti_grade_params(assignment, project, grade)
      { grade: { project_id: project.id, assignment_id: assignment.id,
                 grade: grade, remarks: "" }, format: :json }
    end

    it "pushes the saved grade to the LMS for the launched assignment" do
      submission = instance_double(LtiScoreSubmission, call: true)
      allow(LtiScoreSubmission).to receive(:new).and_return(submission)

      prime_lti_session(consumer_key)
      post grades_path, params: lti_grade_params(@lti_assignment, @lti_project, "80")

      expect(LtiScoreSubmission).to have_received(:new)
        .with(hash_including(score: 0.8, lis_outcome_service_url: outcome_url))
      expect(submission).to have_received(:call)
    end

    it "keeps the grade saved and succeeds when the LMS passback raises" do
      submission = instance_double(LtiScoreSubmission)
      allow(submission).to receive(:call).and_raise(SocketError, "connection refused")
      allow(LtiScoreSubmission).to receive(:new).and_return(submission)

      prime_lti_session(consumer_key)
      expect do
        post grades_path, params: lti_grade_params(@lti_assignment, @lti_project, "80")
      end.to change(Grade, :count).by(1)

      expect(response).to have_http_status(:ok)
    end

    it "does not push the grade to the LMS when the grade fails to save" do
      allow(LtiScoreSubmission).to receive(:new)

      prime_lti_session(consumer_key)
      post grades_path, params: lti_grade_params(@lti_assignment, @lti_project, "abc")

      expect(response).to have_http_status(:bad_request)
      expect(LtiScoreSubmission).not_to have_received(:new)
    end

    it "does not push the grade when the launch context belongs to another assignment" do
      FactoryBot.create(:assignment, group: @group, grading_scale: :percent,
                                     lti_consumer_key: "other-key", lti_shared_secret: "secret")
      allow(LtiScoreSubmission).to receive(:new)

      prime_lti_session("other-key")
      post grades_path, params: lti_grade_params(@lti_assignment, @lti_project, "80")

      expect(LtiScoreSubmission).not_to have_received(:new)
    end

    it "does not push the grade when the project has no LMS result id" do
      @lti_project.update!(lis_result_sourced_id: nil)
      allow(LtiScoreSubmission).to receive(:new)

      prime_lti_session(consumer_key)
      post grades_path, params: lti_grade_params(@lti_assignment, @lti_project, "80")

      expect(LtiScoreSubmission).not_to have_received(:new)
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
      @assignment.update!(deadline: 1.day.ago)
    end

    context "when signed user is primary_mentor" do
      it "creates csv file for grades" do
        sign_in @primary_mentor
        get grades_to_csv_path(@assignment, format: :csv)
        expect(response.body).to include("#{@assignment_project.author.email}," \
                                         "#{@assignment_project.author.name},#{@grade.grade},#{@grade.remarks}")
      end
    end

    context "when signed user is a mentor" do
      it "allows csv export" do
        sign_in_group_mentor(@group)
        get grades_to_csv_path(@assignment, format: :csv)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(@assignment_project.author.email)
      end
    end

    context "when signed user is not a mentor" do
      it "returns unauthorized error" do
        sign_in FactoryBot.create(:user)
        get grades_to_csv_path(@assignment, format: :csv)
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include("Not Authorized:")
      end
    end

    context "when deadline has not passed" do
      it "returns unauthorized error" do
        @assignment.update!(deadline: 1.day.from_now)
        sign_in @primary_mentor
        get grades_to_csv_path(@assignment, format: :csv)
        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include("Not Authorized:")
      end
    end

    context "when assignment does not exist" do
      it "returns not found" do
        sign_in @primary_mentor
        get grades_to_csv_path(99_999, format: :csv)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
