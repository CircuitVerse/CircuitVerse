# frozen_string_literal: true

class CircuitCardComponentPreview < ViewComponent::Preview
  # Circuit Card
  # This component is used to render a card with a given Circuit and user
  # @param project [String]

  def default(project: "Full Adder")
    project_record = Project.find_by(name: project) ||
                     Project.create!(name: project, author: user_record, project_access_type: "Public")

    render(CircuitCardComponent.new(circuit: project_record))
  end
end
