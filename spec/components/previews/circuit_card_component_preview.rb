# frozen_string_literal: true

class CircuitCardComponentPreview < ViewComponent::Preview
  # Circuit Card
  # This component is used to render a card with a given Circuit and user
  # @param project [String]
  # @param user [String]

  def default(project: "Full Adder", user: "user1")
    user_record = User.find_by(name: user) || User.create!(name: user, email: "#{user}@example.com")
    project_record = Project.find_by(name: project) ||
                     Project.create!(name: project, author: user_record, project_access_type: "Public")

    render(CircuitCardComponent.new(
      circuit: project_record,
      current_user: user_record
    ))
  end
end
