# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lti::GradePassbackJob, type: :job do
  describe "#perform" do
    let(:fake_submission) { double("submission", id: 42) }

    before do
      fake_model = Class.new do
        def self.includes(*); self; end
        def self.find(id) = raise(ActiveRecord::RecordNotFound)
      end
      stub_const("AssignmentSubmission", fake_model)
    end

    it "calls GradePassbackService.send_score with the submission" do
      allow(AssignmentSubmission).to receive(:find).and_return(fake_submission)
      allow(Lti::GradePassbackService).to receive(:send_score)
      described_class.perform_now(42)
      expect(Lti::GradePassbackService).to have_received(:send_score).with(fake_submission)
    end

    it "logs a warning and does not raise when submission is not found" do
      allow(Rails.logger).to receive(:warn)
      expect { described_class.perform_now(-1) }.not_to raise_error
      expect(Rails.logger).to have_received(:warn).with(/not found/)
    end

    it "logs and re-raises unexpected errors so Sidekiq can retry" do
      allow(AssignmentSubmission).to receive(:find).and_return(fake_submission)
      allow(Lti::GradePassbackService).to receive(:send_score).and_raise(StandardError, "timeout")
      allow(Rails.logger).to receive(:error)
      expect { described_class.perform_now(42) }.to raise_error(StandardError, "timeout")
    end
  end
end
