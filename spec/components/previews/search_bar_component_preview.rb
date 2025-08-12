# frozen_string_literal: true

class SearchBarComponentPreview < ViewComponent::Preview
  def default
    render(Search::SearchBarComponent.new)
  end

  def with_custom_parameters
    render(
      Search::SearchBarComponent.new(
        search_path: "/admin/search",
        resource_options: %w[Admins Teachers Students],
        options: {
          placeholders: {
            "Admins" => "Search for admins",
            "Teachers" => "Search for teachers",
            "Students" => "Search for students"
          },
          option_labels: {
            "Admins" => "Admins",
            "Teachers" => "Teachers",
            "Students" => "Students"
          }
        },
        resource: "Teachers"
      )
    )
  end
end
