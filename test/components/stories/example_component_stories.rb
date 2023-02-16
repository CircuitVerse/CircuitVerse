class ProjectEmbedComponentStories < ViewComponent::Storybook::Stories
  def initialize(project)
    super
    render ProjectEmbedComponent.new(@project)  
  end
end