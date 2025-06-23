# frozen_string_literal: true

class ProjectCardComponentPreview < ViewComponent::Preview
  def default
    render(Project::ProjectCardComponent.new(project: Project.first))
  end
end
