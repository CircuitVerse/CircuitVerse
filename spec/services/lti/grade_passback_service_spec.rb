# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lti::GradePassbackService do
  describe ".send_score" do
    context "when assignment is not LTI-enabled" do
      let(:assignment) { create(:assignment, lti_deployment: nil, lti_consumer_key: nil, lti_shared_secret: nil) }
      let(:submission) { create(:assignment_submission, assignment: assignment) }

      it "returns early without calling any score service" do
        allow(LtiScoreSubmission).to receive(:new)
        described_class.send_score(submission)
        expect(LtiScoreSubmission).not_to have_received(:new)
      end
    end

    context "LTI 1.1 path" do
      let(:assignment) do
        create(:assignment,
               lti_version:             :v1_1,
               lti_consumer_key:        "key",
               lti_shared_secret:       "secret",
               lis_outcome_service_url: "https://canvas.example.com/outcomes")
      end
      let(:project)    { create(:project, lis_result_sourced_id: "sourced-123") }
      let(:submission) { create(:assignment_submission, assignment: assignment, project: project, score: 80) }

      it "calls LtiScoreSubmission with normalised 0-1 score" do
        score_service = instance_double(LtiScoreSubmission, call: true)
        allow(LtiScoreSubmission).to receive(:new).and_return(score_service)

        described_class.send_score(submission)

        expect(LtiScoreSubmission).to have_received(:new).with(
          hash_including(score: 0.8)
        )
      end

      it "skips when lis_outcome_service_url is blank" do
        assignment.update!(lis_outcome_service_url: nil)
        allow(LtiScoreSubmission).to receive(:new)
        described_class.send_score(submission)
        expect(LtiScoreSubmission).not_to have_received(:new)
      end

      it "skips when lis_result_sourced_id is blank" do
        project.update_column(:lis_result_sourced_id, nil)
        allow(LtiScoreSubmission).to receive(:new)
        described_class.send_score(submission)
        expect(LtiScoreSubmission).not_to have_received(:new)
      end
    end
  end
end
