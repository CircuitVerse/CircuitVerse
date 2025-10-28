# frozen_string_literal: true

class StatCardComponentPreview < ViewComponent::Preview
  def default
    render(Home::StatCardComponent.new(number: "1,234", label: "Circuits Created"))
  end

  def large_number
    render(Home::StatCardComponent.new(number: "10K+", label: "Users"))
  end
end
