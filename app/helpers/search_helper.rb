# frozen_string_literal: true

module SearchHelper
  MAX_RESULTS_PER_PAGE = 5

  def query(resource, query_params)
    page = query_params[:page].to_i
    page = 1 if page < 1

    case resource
    when "Users"
      # User query
      return UsersQuery.new(query_params.merge(page: page)).results, "/users/circuitverse/search"
    when "Projects"
      # Project query
      return ProjectsQuery.new(query_params.merge(page: page), Project.public_and_not_forked).results,
       "/projects/search"
    end
  end
end
