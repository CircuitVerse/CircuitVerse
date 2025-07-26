# frozen_string_literal: true

class SearchBarComponentPreview < ViewComponent::Preview
  def default
    render(Search::SearchBarComponent.new)
  end
end
