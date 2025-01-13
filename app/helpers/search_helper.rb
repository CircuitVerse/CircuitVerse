# frozen_string_literal: true

module SearchHelper
  MAX_RESULTS_PER_PAGE = 5

  def query(resource, query_params, params_y)
    case resource
    when "Users"
      results = UsersQuery.new(query_params, params_y).results
      return results, "/users/circuitverse/search"

    when "Projects"
      results = ProjectsQuery.new(query_params, params_y).results
      return results, "/projects/search"
    else
      return [], nil
    end
  end
end
