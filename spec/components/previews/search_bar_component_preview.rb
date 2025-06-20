# frozen_string_literal: true

class SearchBarComponentPreview < ViewComponent::Preview
  def default
    render(SearchComponents::SearchBarComponent.new)
  end

  def with_custom_parameters
    render(
      SearchComponents::SearchBarComponent.new(
        search_path: "/admin/search",
        resource_options: %w[Admins Teachers Students],
        placeholders: {
          "Admins" => "Search for admins",
          "Teachers" => "Search for teachers",
          "Students" => "Search for students"
        },
        resource: "Teachers",
        query: "john"
      )
    )
  end
end
