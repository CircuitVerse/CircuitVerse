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
      @assignment.update!(status: "closed")
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

      it "freezes student projects as submissions" do
        @assignment.update!(status: "open", deadline: Time.zone.now - 10)
        project = FactoryBot.create(:project, assignment: @assignment, author: FactoryBot.create(:user))
        described_class.perform_now(@assignment.id)

        submission = @assignment.projects.find_by(forked_project_id: project.id)
        expect(submission.project_submission).to be(true)
        expect(project.reload.assignment_id).to be_nil
      end

      it "keeps the scheduled deadline when closing" do
        deadline = Time.zone.now - 10
        @assignment.update!(status: "open", deadline: deadline)
        described_class.perform_now(@assignment.id)
        expect(@assignment.reload.deadline).to be_within(1.second).of(deadline)
      end
    end
  end
end
