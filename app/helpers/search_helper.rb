# frozen_string_literal: true

module SearchHelper
  MAX_RESULTS_PER_PAGE = 5

  def query(resource, query_params)
    case resource
    when "Users"
      # User query
      return UsersQuery.new.results(query_params), "/users/logix/search"
    when "Projects"
      # Project query
      return ProjectsQuery.new(Project.public_and_not_forked).results(query_params),
       "/projects/search"
    end
  end
end
