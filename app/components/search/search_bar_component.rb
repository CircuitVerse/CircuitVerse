# frozen_string_literal: true

class Search::SearchBarComponent < ViewComponent::Base
  RESOURCE_OPTIONS = %w[Users Projects].freeze
  DEFAULT_SORT_BY = "created_at".freeze
  DEFAULT_SORT_DIRECTION = "desc".freeze

  def initialize(
    resource: nil,
    query: nil,
    sort_by: nil,
    sort_direction: nil
  )
    super
    @resource = resource
    @query = query
    @sort_by = sort_by || DEFAULT_SORT_BY
    @sort_direction = sort_direction || DEFAULT_SORT_DIRECTION
  end

  attr_reader :resource, :query, :sort_by, :sort_direction

  def all_sorting_options
    {
      "Users" => sorting_options_for_users,
      "Projects" => sorting_options_for_projects
    }.freeze
  end

  def resource_options
    RESOURCE_OPTIONS
  end

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

  private

    def sorting_options_for_users
      [
        { value: "created_at", label: I18n.t("components.search_bar.sorting.users.join_date") }.freeze,
        { value: "total_circuits", label: I18n.t("components.search_bar.sorting.users.total_circuits") }.freeze
      ].freeze
    end

    def sorting_options_for_projects
      [
        { value: "created_at", label: I18n.t("components.search_bar.sorting.projects.created_date") }.freeze,
        { value: "views", label: I18n.t("components.search_bar.sorting.projects.views") }.freeze,
        { value: "stars", label: I18n.t("components.search_bar.sorting.projects.stars") }.freeze
      ].freeze
    end
end
