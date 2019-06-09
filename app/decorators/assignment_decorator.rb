# frozen_string_literal: true

class AssignmentDecorator < SimpleDelegator
  def assignment
    __getobj__
  end

  def graded
    assignment.graded? ? "Graded(#{assignment.grading_scale})" : "Not Graded"
  end
end
