# frozen_string_literal: true

module Adapters
  class SolrAdapter < BaseAdapter
    # @type [Integer]
    MAX_RESULTS_PER_PAGE = 5

    # @param [ActiveRecord::Relation] relation
    # @param [Hash] query_params
    # @return [Array<Project>]
    def search_project(relation, query_params)
      if query_params[:q].present?
        relation.search(include: %i[tags author]) do
          fulltext query_params[:q]
          paginate page: query_params[:page], per_page: MAX_RESULTS_PER_PAGE
        end.results
      else
        Project.public_and_not_forked
      end
    end

    # @param [ActiveRecord::Relation] relation
    # @param [Hash] query_params
    # @return [Array<User>]
    def search_user(relation, query_params)
      if query_params[:q].present?
        relation.search do
          fulltext query_params[:q]
          paginate page: query_params[:page], per_page: MAX_RESULTS_PER_PAGE
        end.results
      else
        User.all
      end
    end
  end
end
