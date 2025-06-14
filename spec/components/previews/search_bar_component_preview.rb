# frozen_string_literal: true

class SearchBarComponentPreview < ViewComponent::Preview
  def default
    render(SearchComponents::SearchBarComponent.new)
  end
end
