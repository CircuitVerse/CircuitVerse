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
    @sort_by = sort_by
    @sort_direction = sort_direction
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
        { value: "created_at", label: "Join Date" },
        { value: "total_circuits", label: "Total Circuits" }
      ]
    end

    def sorting_options_for_projects
      [
        { value: "created_at", label: "Created Date" },
        { value: "views", label: "Views" },
        { value: "stars", label: "Stars" }
      ]
    end

    def current_sorting_options
      resource == "Users" ? sorting_options_for_users : sorting_options_for_projects
    end
end
