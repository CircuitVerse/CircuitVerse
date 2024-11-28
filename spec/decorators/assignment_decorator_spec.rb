# frozen_string_literal: true

require "rails_helper"

describe AssignmentDecorator do
  def decorated_assignment
    AssignmentDecorator.new(@assignment)
  end

  before do
    group = create(:group, primary_mentor: create(:user))
    @assignment = create(:assignment, group: group, grading_scale: :letter)
  end

  describe "#graded" do
    it "gives grading status" do
      expect(decorated_assignment.graded).to eq("Graded(letter)")
      @assignment.grading_scale = :no_scale
      expect(decorated_assignment.graded).to eq("Not Graded")
    end
  end
end
