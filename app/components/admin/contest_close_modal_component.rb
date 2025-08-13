# frozen_string_literal: true

class Admin::ContestCloseModalComponent < ViewComponent::Base
  def initialize(contest:)
    super()
    @contest = contest
  end
end
