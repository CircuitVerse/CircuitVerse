# frozen_string_literal: true

class SearchBarComponentPreview < ViewComponent::Preview
  def default
    render(SearchComponents::SearchBarComponent.new)
  end

  def with_custom_options
    render(SearchComponents::SearchBarComponent.new(
      resource_options: %w[Courses Assignments Groups],
      placeholders: {
        "Courses" => "Search for courses",
        "Assignments" => "Search for assignments",
        "Groups" => "Search for groups"
      }
    ))
  end

  def with_autocomplete_enabled
    render(SearchComponents::SearchBarComponent.new(
      autocomplete: "on"
    ))
  end

  def with_all_custom_parameters
    render(SearchComponents::SearchBarComponent.new(
      search_path: "/admin/search",
      resource_options: %w[Admins Teachers Students],
      placeholders: {
        "Admins" => "Search for admins",
        "Teachers" => "Search for teachers",
        "Students" => "Search for students"
      },
      autocomplete: "on",
      resource: "Teachers",
      query: "john"
    ))
  end
end
