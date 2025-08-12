# frozen_string_literal: true

class Search::SearchBarComponent < ViewComponent::Base
  def initialize(
    resource: nil,
    query: nil,
    search_path: "/search",
    resource_options: %w[Users Projects],
    options: {}
  )
    super
    @resource = resource
    @query = query
    @search_path = search_path
    @resource_options = resource_options
    @placeholders = options[:placeholders] || default_placeholders
    @option_labels = options[:option_labels] || default_option_labels
  end

  private

    attr_reader :resource, :query, :search_path, :resource_options, :placeholders, :option_labels

    def default_placeholders
      {
        "Users" => I18n.t("components.search_bar.placeholders.users"),
        "Projects" => I18n.t("components.search_bar.placeholders.projects")
      }
    end

    def default_option_labels
      {
        "Users" => I18n.t("components.search_bar.options.users"),
        "Projects" => I18n.t("components.search_bar.options.projects")
      }
    end
end
