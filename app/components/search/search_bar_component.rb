# frozen_string_literal: true

class Search::SearchBarComponent < ViewComponent::Base
  def initialize(
    resource: nil,
    query: nil,
    sort_by: nil,
    sort_direction: nil
  )
    super
    @resource = resource
    @query = query
    @sort_by = sort_by || default_sort_by
    @sort_direction = sort_direction || default_sort_direction
  end

  def all_sorting_options
    {
      "Users" => sorting_options_for_users,
      "Projects" => sorting_options_for_projects
    }
  end

  private

    attr_reader :resource, :query, :sort_by, :sort_direction

    def resource_options
      ["Users", "Projects"]
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

    def sorting_options_for_users
      [
        { value: "created_at", label: I18n.t("components.search_bar.sorting.users.join_date") },
        { value: "total_circuits", label: I18n.t("components.search_bar.sorting.users.total_circuits") }
      ]
    end

    def sorting_options_for_projects
      [
        { value: "created_at", label: I18n.t("components.search_bar.sorting.projects.created_date") },
        { value: "views", label: I18n.t("components.search_bar.sorting.projects.views") },
        { value: "stars", label: I18n.t("components.search_bar.sorting.projects.stars") }
      ]
    end

    def current_sorting_options
      resource == "Users" ? sorting_options_for_users : sorting_options_for_projects
    end

    def default_sort_by
      "created_at"
    end

    def default_sort_direction
      "desc" # Default to descending (newest first)
    end
end
