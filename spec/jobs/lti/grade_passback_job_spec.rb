# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lti::GradePassbackJob, type: :job do
  describe "#perform" do
    let(:submission) { create(:assignment_submission) }

    context "when the submission exists" do
      it "calls GradePassbackService.send_score with the submission" do
        allow(Lti::GradePassbackService).to receive(:send_score)

        described_class.perform_now(submission.id)

        expect(Lti::GradePassbackService).to have_received(:send_score) do |arg|
          expect(arg.id).to eq(submission.id)
        end
      end
    end

    context "when the submission does not exist" do
      it "logs the error and does not raise" do
        allow(Rails.logger).to receive(:error)

        expect { described_class.perform_now(-1) }.not_to raise_error

        expect(Rails.logger).to have_received(:error).with(
          a_string_matching(/GradePassbackJob submission not found/)
        )
      end
    end

    context "when GradePassbackService raises an unexpected error" do
      it "re-raises so the queue can retry" do
        allow(Lti::GradePassbackService).to receive(:send_score)
          .and_raise(StandardError, "network timeout")
        allow(Rails.logger).to receive(:error)

        expect { described_class.perform_now(submission.id) }.to raise_error(StandardError, "network timeout")
      end
    end
  end
end
