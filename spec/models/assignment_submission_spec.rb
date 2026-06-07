# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignmentSubmission, type: :model do
  describe "#verification_score" do
    subject(:submission) { build(:assignment_submission, score: score) }

    context "when score is nil" do
      let(:score) { nil }

      it "returns 0.0" do
        expect(submission.verification_score).to eq(0.0)
      end
    end

    context "when score is 0" do
      let(:score) { 0 }

      it "returns 0.0" do
        expect(submission.verification_score).to eq(0.0)
      end
    end

    context "when score is 100" do
      let(:score) { 100 }

      it "returns 1.0" do
        expect(submission.verification_score).to eq(1.0)
      end
    end

    context "when score is 75" do
      let(:score) { 75 }

      it "returns 0.75" do
        expect(submission.verification_score).to eq(0.75)
      end
    end

    context "when score is above 100 (data integrity edge case)" do
      let(:score) { 120 }

      it "clamps to 1.0" do
        expect(submission.verification_score).to eq(1.0)
      end
    end

    context "when score is negative (data integrity edge case)" do
      let(:score) { -10 }

      it "clamps to 0.0" do
        expect(submission.verification_score).to eq(0.0)
      end
    end
  end

  describe "validations" do
    it "is invalid without an assignment" do
      submission = build(:assignment_submission, assignment: nil)
      expect(submission).not_to be_valid
    end

    it "is invalid without a project" do
      submission = build(:assignment_submission, project: nil)
      expect(submission).not_to be_valid
    end

    it "enforces uniqueness of project per assignment" do
      existing = create(:assignment_submission)
      duplicate = build(:assignment_submission,
                        assignment: existing.assignment,
                        project:    existing.project)
      expect(duplicate).not_to be_valid
    end
  end

  describe "status enum" do
    it "starts as draft by default" do
      submission = create(:assignment_submission)
      expect(submission.status_draft?).to be true
    end

    it "transitions to submitted" do
      submission = create(:assignment_submission)
      submission.status_submitted!
      expect(submission.reload.status_submitted?).to be true
    end

    it "transitions to graded" do
      submission = create(:assignment_submission, status: :submitted)
      submission.status_graded!
      expect(submission.reload.status_graded?).to be true
    end
  end
end
