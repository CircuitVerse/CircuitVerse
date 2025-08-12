# frozen_string_literal: true

class Contest::LeaderboardPageComponent < ViewComponent::Base
  def initialize(contest:, submissions:)
    super()
    @contest = contest
    @submissions = submissions
  end
end
