class ExampleComponentStories < ViewComponent::Storybook::Stories
  def hello_world
    super
    render ExampleComponent.new(title: "my title") do
      "Hello World!"
    end 
  end
end