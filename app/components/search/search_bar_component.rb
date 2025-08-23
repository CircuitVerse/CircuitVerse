# frozen_string_literal: true

class Search::SearchBarComponent < ViewComponent::Base
  RESOURCE_OPTIONS = %w[Projects Users].freeze
  DEFAULT_SORT_BY = "created_at".freeze
  DEFAULT_SORT_DIRECTION = "desc".freeze

  def initialize(
    resource: nil,
    query: nil,
    sort_by: nil,
    sort_direction: nil,
    countries: nil,
    current_filters: nil
  )
    super
    @resource = resource
    @query = query
    @sort_by = sort_by || default_sort_by
    @sort_direction = sort_direction || default_sort_direction
    @countries = countries || []
    @current_filters = current_filters || {}
  end

  def all_sorting_options
    {
      "Users" => sorting_options_for_users,
      "Projects" => sorting_options_for_projects
    }
  end

  def countries_for_search
    @countries
  end

  def current_filter_values
    @current_filters
  end

  def filter_labels
    {
      "button_text" => I18n.t("components.search_bar.filters.button_text"),
      "apply_button_text" => I18n.t("components.search_bar.filters.apply_button_text"),
      "projects" => {
        "tags" => {
          "label" => I18n.t("components.search_bar.filters.projects.tags.label"),
          "placeholder" => I18n.t("components.search_bar.filters.projects.tags.placeholder")
        }
      },
      "users" => {
        "country" => {
          "label" => I18n.t("components.search_bar.filters.users.country.label"),
          "placeholder" => I18n.t("components.search_bar.filters.users.country.placeholder")
        },
        "institute" => {
          "label" => I18n.t("components.search_bar.filters.users.institute.label"),
          "placeholder" => I18n.t("components.search_bar.filters.users.institute.placeholder")
        }
      }
    }
  end

  private

    attr_reader :resource, :query, :sort_by, :sort_direction, :countries, :current_filters

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
