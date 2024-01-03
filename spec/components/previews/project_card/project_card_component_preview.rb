# frozen_string_literal: true

class ProjectCard::ProjectCardComponentPreview < ViewComponent::Preview
  def default
    render(ProjectCard::ProjectCardComponent.new(
             Project.new(id: 1, author_id: 1),
             User.new(id: 1)
           ))
  end

  def private_project
    render(ProjectCard::ProjectCardComponent.new(
             Project.new(id: 1, author_id: 1, project_access_type: "private"),
             User.new(id: 1)
           ))
  end
end
