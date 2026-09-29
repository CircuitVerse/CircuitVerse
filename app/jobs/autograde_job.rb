# frozen_string_literal: true

class AutogradeJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    project = Project.find_by(id: project_id)
    assignment = project&.assignment
    testbench = assignment&.testbench
    return unless testbench

    max = assignment.max_attempts
    return if max && GradingResult.where(project: project).count >= max

    begin
      result = Autograder::Runner.call(project: project, testbench: testbench)
      breakdown = result.groups
      score = (result.score * 100).round(2)
    rescue Autograder::Runner::RunnerError
      breakdown = []
      score = nil
    end

    GradingResult.create!(project: project, suite_snapshot: testbench.data, breakdown: breakdown, score: score)
  end
end
