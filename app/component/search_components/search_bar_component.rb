# frozen_string_literal: true

module SearchComponents
  class SearchBarComponent < ViewComponent::Base
    def initialize(
      resource: nil,
      query: nil,
      search_path: "/search",
      resource_options: %w[Users Projects],
      placeholders: nil
    )
      super
      @resource = resource
      @query = query
      @search_path = search_path
      @resource_options = resource_options
      @placeholders = placeholders || default_placeholders
    end

    private

      attr_reader :resource, :query, :search_path, :resource_options, :placeholders

      def default_placeholders
        {
          "Users" => I18n.t("components.search_bar.placeholders.users"),
          "Projects" => I18n.t("components.search_bar.placeholders.projects")
        }
      end
  end
end
