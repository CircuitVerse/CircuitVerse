# frozen_string_literal: true

class CircuitCardComponentPreview < ViewComponent::Preview
  # Circuit Card
  # This component is used to render a card with a given Circuit and user
  # @param projectName [String]
  # @param userName [String]

  def default(projectName: "Full Adder", userName: "user1")
    render(CircuitCardComponent.new(circuit: Project.find_by(name: projectName),
                                    current_user: User.find_by(name: userName)))
  end
end
