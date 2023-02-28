class ProjectEmbedComponentStories < ViewComponent::Storybook::Stories
    def project_embed
      super
      render ProjectEmbedComponent.new(project) do
        project
      end 
    end
  end