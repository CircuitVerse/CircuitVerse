# frozen_string_literal: true

class Search::SearchBarComponent < ViewComponent::Base
  def initialize(
    resource: nil,
    query: nil
  )
    super
    @resource = resource
    @query = query
  end

  private

    attr_reader :resource, :query

    def resource_options
      %w[Users Projects]
    end

    def placeholders
      {
        "Users" => I18n.t("components.search_bar.placeholders.users"),
        "Projects" => I18n.t("components.search_bar.placeholders.projects")
      }
    end

    def option_labels
      {
        "Users" => I18n.t("components.search_bar.options.users"),
        "Projects" => I18n.t("components.search_bar.options.projects")
      }
    end
end
