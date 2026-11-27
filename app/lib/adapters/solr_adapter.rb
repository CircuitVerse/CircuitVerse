# frozen_string_literal: true

module Adapters
  class SolrAdapter < BaseAdapter
    def search_project(relation, query_params)
      if query_params[:q].present?
        relation.search(include: %i[tags author]) do
          fulltext query_params[:q]
        end.results
      else
        Project.public_and_not_forked
      end
    end

    def search_user(relation, query_params)
      if query_params[:q].present?
        relation.search do
          fulltext query_params[:q]
        end.results
      else
        User.all
      end
    end
  end
end
