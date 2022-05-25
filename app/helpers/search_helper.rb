# frozen_string_literal: true

module SearchHelper
  MAX_RESULTS_PER_PAGE = 5

  def query(resource,filter, query_params)
    case resource
    when "Users"
      # User query
      return UsersQuery.new(query_params).results, "/users/circuitverse/search"
    when "Projects"
      # Project query
      case filter
      when "All"
        return ProjectsQuery.new(query_params, Project.public_and_not_forked).results, "/projects/search"
      when "Most Viewed"
        return ProjectsQuery.new(query_params, Project.most_viewed).results, "/projects/search"
      when "My projects"
        return ProjectsQuery.new(query_params, Project.by_and_not_forked(current_user)).results, "/projects/search"
      when "Private"
        return ProjectsQuery.new(query_params, Project.private_projects(current_user)).results, "/projects/search"
      when "Featured"
        return ProjectsQuery.new(query_params, Project.featured_project).results, "/projects/search"
      end
    end
  end
end
