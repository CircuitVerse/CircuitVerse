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
    end

    describe "when the assignment is reopening" do
      before do
        @assignment.update!(status: "reopening", deadline: Time.zone.now - 10)
        @project = FactoryBot.create(:project, assignment: @assignment, author: @primary_mentor)
        @project.circuit_preview.attach(io: StringIO.new("preview"), filename: "preview.png",
                                        content_type: "image/png")
      end

      it "snapshots the projects, detaches the originals and closes the assignment" do
        described_class.perform_now(@assignment.id)

        @assignment.reload
        expect(@assignment.status).to eq("closed")
        expect(@assignment.projects.count).to eq(1)
        expect(@assignment.projects.first.project_submission).to be(true)
        expect(@project.reload.assignment_id).to be_nil
      end

      it "does not create another snapshot when run again" do
        described_class.perform_now(@assignment.id)

        expect { described_class.perform_now(@assignment.id) }.not_to change(Project, :count)
      end
    end
  end
end
