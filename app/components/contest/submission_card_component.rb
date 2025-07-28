# frozen_string_literal: true

class Contest::SubmissionCardComponent < ViewComponent::Base
  def initialize(submission:, contest:, current_user:)
    @submission  = submission
    @contest     = contest
    @current_user = current_user
  end

  delegate :project, to: :@submission
end
