# frozen_string_literal: true

module Adapters
  class PgAdapter < BaseAdapter
    MAX_RESULTS_PER_PAGE = 5

    def search_project(relation, query_params)
      cursor = query_params[:cursor].presence || nil
      results = if query_params[:q].present?
        relation.text_search(query_params[:q])
      else
        Project.public_and_not_forked
      end

      results = results.order(id: :asc).includes(:tags, :author)

      # Apply cursor pagination if cursor is provided
      if cursor
        results = results.cursor_paginate(after: cursor, limit: MAX_RESULTS_PER_PAGE)
      else
        results = results.limit(MAX_RESULTS_PER_PAGE)
      end

      # Return the actual records
      results
    end

    def search_user(relation, query_params)
      cursor = query_params[:cursor].presence

      results = if query_params[:q].present?
        relation.text_search(query_params[:q])
      else
        User.all
      end

      results = results.order(id: :asc)

      # Apply cursor pagination based on cursor
      if cursor
        results = results.cursor_paginate(after: cursor, limit: MAX_RESULTS_PER_PAGE)
      else
        results = results.limit(MAX_RESULTS_PER_PAGE + 2)
      end

      # Return the actual records
      results
    end
  end
end
