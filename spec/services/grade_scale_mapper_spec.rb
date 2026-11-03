# frozen_string_literal: true

require "rails_helper"

RSpec.describe GradeScaleMapper do
  let(:group) { FactoryBot.create(:group, primary_mentor: FactoryBot.create(:user)) }
  let(:assignment) { FactoryBot.create(:assignment, group: group, grading_scale: :percent) }

  describe ".call" do
    it "maps a fraction to a percent string" do
      expect(described_class.call(assignment, 0.5)).to eq("50")
    end

    it "maps a fraction to a letter grade" do
      assignment.update!(grading_scale: :letter)
      expect(described_class.call(assignment, 0.95)).to eq("A")
      expect(described_class.call(assignment, 0.55)).to eq("E")
      expect(described_class.call(assignment, 0.1)).to eq("F")
    end

    it "clamps out-of-range fractions" do
      expect(described_class.call(assignment, 1.2)).to eq("100")
    end

    it "refuses to map when the assignment has no scale" do
      assignment.update!(grading_scale: :no_scale)
      expect(described_class.call(assignment, 0.5)).to be_nil
    end

    it "forces percent when the assignment is LTI-integrated" do
      assignment.update!(grading_scale: :percent, lti_consumer_key: "key", lti_shared_secret: "secret")
      expect(described_class.call(assignment, 0.75)).to eq("75")
    end
  end

  describe ".mappable?" do
    it "is false for no_scale" do
      assignment.update!(grading_scale: :no_scale)
      expect(described_class.mappable?(assignment)).to be false
    end
  end
end
