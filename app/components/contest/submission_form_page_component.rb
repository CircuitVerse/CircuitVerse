# frozen_string_literal: true

class Contest::SubmissionFormPageComponent < ViewComponent::Base
  def initialize(contest:, projects:, submission:, notice: nil)
    super()
    @contest    = contest
    @projects   = projects
    @submission = submission
    @notice     = notice
  end

  attr_reader :contest, :projects, :submission, :notice
end
