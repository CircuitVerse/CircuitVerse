# frozen_string_literal: true

class Contest::WithdrawModalComponent < ViewComponent::Base
  def initialize(contest:, submission:)
    @contest    = contest
    @submission = submission
  end
end
