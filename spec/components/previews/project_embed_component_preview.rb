class ProjectEmbedComponentPreview < ViewComponent::Preview
  def component
    render(ProjectEmbedComponent.new(Project.new(id: 1)))
  end
end
