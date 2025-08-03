# frozen_string_literal: true

class Admin::ContestHostNewModalComponent < ViewComponent::Base
  def initialize(default_deadline: 1.month.from_now)
    @default_deadline = default_deadline
  end
end
