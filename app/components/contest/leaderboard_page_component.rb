# frozen_string_literal: true

class Contest::LeaderboardPageComponent < ViewComponent::Base
  def initialize(contest:, submissions:)
    @contest = contest
    @submissions = submissions
    super()
  end
end
