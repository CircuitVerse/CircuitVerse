# frozen_string_literal: true

module SearchHelper
  MAX_RESULTS_PER_PAGE = 5

  def query(resource, query_params)
    case resource
    when "Users"
      # User query
      return UsersQuery.new(query_params).results, "/users/circuitverse/search"
    when "Projects"
      # Project query
      return ProjectsQuery.new(query_params, Project.public_and_not_forked).results,
       "/projects/search"
    end
  end
end
