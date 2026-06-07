# frozen_string_literal: true

module Lti
  class CanvasOutcomesService
    def initialize(deployment, assignment)
      @deployment = deployment
      @assignment = assignment
    end

    def report_outcomes(submission, verification_result)
      return unless @deployment.present?
      outcomes = build_outcome_results(submission, verification_result)
      post_to_canvas(outcomes)
    end

    private

    def build_outcome_results(submission, result)
      {
        outcome_results: result.failed_cases.map do |tc|
          {
            association_type: "Assignment",
            association_id:   @assignment.canvas_assignment_id,
            score:            0,
            possible:         1,
            mastery:          false,
            title:            tc.description
          }
        end
      }
    end

    def post_to_canvas(outcomes)
      # Full implementation during GSoC
      # Requires Canvas API token from LTI launch claims
      Rails.logger.info "Canvas Outcomes: #{outcomes.to_json}"
    end
  end
end
