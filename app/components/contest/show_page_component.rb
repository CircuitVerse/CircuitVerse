# frozen_string_literal: true

class Contest::ShowPageComponent < ViewComponent::Base
  # rubocop:disable Metrics/ParameterLists
  def initialize(contest:, user_count:, submissions:, user_submissions:,
                 winner:, current_user:, notice: nil)
    super()
    @contest          = contest
    @user_count       = user_count
    @submissions      = submissions
    @user_submissions = user_submissions
    @winner           = winner
    @current_user     = current_user
    @notice           = notice
  end
  # rubocop:enable Metrics/ParameterLists

  attr_reader :contest, :user_count, :submissions, :user_submissions,
              :winner, :current_user, :notice
end
