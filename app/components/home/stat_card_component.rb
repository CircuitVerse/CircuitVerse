# frozen_string_literal: true

class Home::StatCardComponent < ViewComponent::Base
  def initialize(number:, label:)
    super()
    @number = number
    @label = label
  end

  private

    attr_reader :number, :label
end
