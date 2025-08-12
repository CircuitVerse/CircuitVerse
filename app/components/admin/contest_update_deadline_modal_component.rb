# frozen_string_literal: true

class Admin::ContestUpdateDeadlineModalComponent < ViewComponent::Base
  def initialize(contest:)
    super()
    @contest = contest
  end

  attr_reader :contest
end
