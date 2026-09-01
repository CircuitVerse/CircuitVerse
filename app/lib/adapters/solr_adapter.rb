# frozen_string_literal: true

module Adapters
  class SolrAdapter < BaseAdapter
    MAX_RESULTS_PER_PAGE = 9

    def search_project(relation, query_params)
      if query_params[:q].present?
        page = sanitize_page(query_params[:page])
        relation.search(include: %i[tags author]) do
          fulltext query_params[:q]
          paginate page: page, per_page: MAX_RESULTS_PER_PAGE
        end.results
      else
        Project.public_and_not_forked
      end
    end

    def search_user(relation, query_params)
      if query_params[:q].present?
        page = sanitize_page(query_params[:page])
        relation.search do
          fulltext query_params[:q]
          paginate page: page, per_page: MAX_RESULTS_PER_PAGE
        end.results
      else
        User.all
      end
    end
  end
end
