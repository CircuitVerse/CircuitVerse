# frozen_string_literal: true

class Search::SearchBarComponent < ViewComponent::Base
  RESOURCE_OPTIONS = %w[Projects Users].freeze
  DEFAULT_SORT_BY = "created_at".freeze
  DEFAULT_SORT_DIRECTION = "desc".freeze

  SORTING_OPTIONS_FOR_USERS = [
    { value: "created_at".freeze, label: -> { I18n.t("components.search_bar.sorting.users.join_date") } },
    { value: "total_circuits".freeze, label: -> { I18n.t("components.search_bar.sorting.users.total_circuits") } }
  ].freeze

  SORTING_OPTIONS_FOR_PROJECTS = [
    { value: "created_at".freeze, label: -> { I18n.t("components.search_bar.sorting.projects.created_date") } },
    { value: "views".freeze, label: -> { I18n.t("components.search_bar.sorting.projects.views") } },
    { value: "stars".freeze, label: -> { I18n.t("components.search_bar.sorting.projects.stars") } }
  ].freeze

  def initialize(
    resource: nil,
    query: nil,
    sorting: {},
    countries: nil,
    current_filters: nil
  )
    super
    @resource = resource
    @query = query
    @sort_by = sorting[:sort_by] || sorting["sort_by"] || DEFAULT_SORT_BY
    @sort_direction = sorting[:sort_direction] || sorting["sort_direction"] || DEFAULT_SORT_DIRECTION
    @countries = countries || []
    @current_filters = current_filters || {}
  end

  def all_sorting_options
    {
      "Users" => sorting_options_for_users,
      "Projects" => sorting_options_for_projects
    }.freeze
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
      "projects" => project_filter_labels,
      "users" => user_filter_labels
    }.freeze
  end

  private

    attr_reader :resource, :query, :sort_by, :sort_direction, :countries, :current_filters

    def placeholders
      {
        "Users" => I18n.t("components.search_bar.placeholders.users"),
        "Projects" => I18n.t("components.search_bar.placeholders.projects")
      }.freeze
    end

    def option_labels
      {
        "Users" => I18n.t("components.search_bar.options.users"),
        "Projects" => I18n.t("components.search_bar.options.projects")
      }.freeze
    end

    def sorting_options_for_users
      SORTING_OPTIONS_FOR_USERS.map { |option| { value: option[:value], label: option[:label].call } }
    end

    def sorting_options_for_projects
      SORTING_OPTIONS_FOR_PROJECTS.map { |option| { value: option[:value], label: option[:label].call } }
    end

    def project_filter_labels
      {
        "tags" => {
          "label" => I18n.t("components.search_bar.filters.projects.tags.label"),
          "placeholder" => I18n.t("components.search_bar.filters.projects.tags.placeholder")
        }.freeze
      }.freeze
    end

    def user_filter_labels
      {
        "country" => {
          "label" => I18n.t("components.search_bar.filters.users.country.label"),
          "placeholder" => I18n.t("components.search_bar.filters.users.country.placeholder")
        }.freeze,
        "institute" => {
          "label" => I18n.t("components.search_bar.filters.users.institute.label"),
          "placeholder" => I18n.t("components.search_bar.filters.users.institute.placeholder")
        }.freeze
      }.freeze
    end
end
