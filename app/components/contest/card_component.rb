# frozen_string_literal: true

class Contest::CardComponent < ViewComponent::Base
  def initialize(contest:)
    super()
    @contest = contest
  end
end
