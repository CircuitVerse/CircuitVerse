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

    it "when the assignment is open and the deadline has not passed" do
      @assignment.status = "open"
      @assignment.deadline = Time.zone.now + 10
      expect(described_class.perform_now(@assignment.id)).to be_nil
    end
  end
end
