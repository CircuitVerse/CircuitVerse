# frozen_string_literal: true

class EditProjectFormComponentPreview < ViewComponent::Preview
  include FactoryBot::Syntax::Methods
  def component
    project = create(:project, name: "Write Something here")
    user = create(:user)
    render(ProjectComponents::EditProjectFormComponent.new(project: project, current_user: user))
  end
end
