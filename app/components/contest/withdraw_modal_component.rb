# frozen_string_literal: true

class Contest::WithdrawModalComponent < ViewComponent::Base
  def initialize(contest:, submission:)
    super()
    @contest    = contest
    @submission = submission
  end
end
