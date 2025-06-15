# frozen_string_literal: true

class ProjectCardComponentPreview < ViewComponent::Preview
  def default
    render(ProjectComponents::ProjectCardComponent.new(project: Project.first))
  end
end
