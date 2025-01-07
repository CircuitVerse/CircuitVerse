# frozen_string_literal: true

# module SearchHelper
#   MAX_RESULTS_PER_PAGE = 5

#   def query(resource, query_params)
#     case resource
#     when "Users"
#       # User query
#       return UsersQuery.new(query_params).results, "/users/circuitverse/search"
#     when "Projects"
#       # Project query
#       return ProjectsQuery.new(query_params, Project.public_and_not_forked).results,
#        "/projects/search"
#     end
#   end
# end

module SearchHelper
  MAX_RESULTS_PER_PAGE = 5

  def query(resource, query_params)
    case resource
    when "Users"
      results, next_cursor, previous_cursor = fetch_paginated_results(UsersQuery.new(query_params).results)
      Rails.logger.info("Query params in SearchHelper: #{query_params.inspect}")
      Rails.logger.info("Results in SearchHelper: #{results.inspect}")
      return results, "/users/circuitverse/search", next_cursor, previous_cursor

    when "Projects"
      results, next_cursor, previous_cursor = fetch_paginated_results(ProjectsQuery.new(query_params, Project.public_and_not_forked).results)
      return results, "/projects/search", next_cursor, previous_cursor
    else
      return [], nil, nil
    end
  end

  private

  def fetch_paginated_results(results)
    if results.respond_to?(:records)
      paginated_results = results.records

      # Handle cursor if present
      next_cursor = paginated_results.any? ? paginated_results.last.id : nil
      previous_cursor = paginated_results.any? ? paginated_results.first.id : nil

      Rails.logger.info("Paginated results: #{paginated_results.inspect}")
      Rails.logger.info("Next cursor: #{next_cursor}, Previous cursor: #{previous_cursor}")

      [paginated_results, next_cursor, previous_cursor]
    else
      Rails.logger.info("No records found in relation for pagination")
      [[], nil, nil]
    end
  end
end
