# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignmentDeadlineSubmissionJob, type: :job do
  before do
    @primary_mentor = FactoryBot.create(:user)
    @group = FactoryBot.create(:group, primary_mentor: @primary_mentor)
    @assignment = FactoryBot.create(:assignment, group: @group)
  end

  describe "#perform" do
    it "when the assignment is nil" do
      expect(described_class.perform_now(nil)).to be_nil
    end

    it "when the assignment is closed" do
      @assignment.status = "closed"
      expect(described_class.perform_now(@assignment.id)).to be_nil
    end

    describe "when the assignment is open" do
      it "if deadline has not passed, don't close" do
        @assignment.status = "open"
        @assignment.deadline = Time.zone.now + 20
        @assignment.save!
        expect(described_class.perform_now(@assignment.id)).to be_nil
        @assignment.reload
        expect(@assignment.status).to eq("open")
      end

      it "if deadline has passed close assignment" do
        @assignment.status = "open"
        @assignment.deadline = Time.zone.now - 10
        @assignment.save!
        expect(described_class.perform_now(@assignment.id)).to be_truthy
        @assignment.reload
        expect(@assignment.status).to eq("closed")
      end

      it "if deadline has passed freeze student submissions" do
        @assignment.status = "open"
        @assignment.deadline = Time.zone.now - 10
        @assignment.save!
        student = FactoryBot.create(:user)
        project = FactoryBot.create(:project, assignment: @assignment, author: student,
                                              project_submission: false)

        expect(described_class.perform_now(@assignment.id)).to be_truthy
        @assignment.reload
        project.reload
        expect(@assignment.status).to eq("closed")
        expect(project.assignment_id).to be_nil
        submission = @assignment.projects.find_by(author: student)
        expect(submission).to be_present
        expect(submission.project_submission).to be(true)
      end
    end
  end
end
