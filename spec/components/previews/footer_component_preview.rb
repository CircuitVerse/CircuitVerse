# frozen_string_literal: true

class FooterComponentPreview < ViewComponent::Preview
  # Default preview for the FooterComponent
  def default
    render(FooterComponent.new(current_user: sample_user))
  end

  private

    def sample_user
      User.new(id: 1, name: "Sample User", email: "sample@example.com")
    end
end
