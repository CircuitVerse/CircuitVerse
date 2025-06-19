# frozen_string_literal: true

module SearchComponents
  class SearchBarComponent < ViewComponent::Base
    def initialize(
      resource: nil,
      query: nil,
      search_path: "/search",
      resource_options: %w[Users Projects],
      placeholders: {
        "Users" => "Search for users",
        "Projects" => "Search for projects"
      },
      autocomplete: "off"
    )
      super
      @resource = resource
      @query = query
      @search_path = search_path
      @resource_options = resource_options
      @placeholders = placeholders
      @autocomplete = autocomplete
    end

    private

      attr_reader :resource, :query, :search_path, :resource_options, :placeholders, :autocomplete
  end
end
