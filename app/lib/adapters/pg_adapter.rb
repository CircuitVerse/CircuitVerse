# frozen_string_literal: true

module Adapters
  class PgAdapter < BaseAdapter
    MAX_RESULTS_PER_PAGE = 5

    def search_project(relation, query_params, params_y)
      result_x = if params_y[:after].present? || params_y[:before].present?
        build_project_query(relation, query_params, params_y)
      else
        build_project_query(relation, query_params, params_y, skip_cursor: true)
        # first search query for projects
      end
        results_z = result_x.fetch
        @results = results_z
        # Return the paginated records
        @results
    end

    def search_user(relation, query_params, params_y)
      result_x = if params_y[:after].present? || params_y[:before].present?
        build_user_query(relation, query_params, params_y)
      else
        build_user_query(relation, query_params, params_y, skip_cursor: true)
        # first search query for users
      end
        results_z = result_x.fetch
        @results = results_z
        # Return the paginated records
        @results
    end

    private

    def build_user_query(relation, query_params, params_y, skip_cursor: false)
      cursor_params = {
        limit: MAX_RESULTS_PER_PAGE
      }

      results_q = if query_params[:q].present?
        relation.text_search(query_params[:q])
      else
        User.all
      end

      unless skip_cursor
        cursor_params[:after] = params_y[:after]
        cursor_params[:before] = params_y[:before]
      end

      results_q = results_q.cursor_paginate(**cursor_params)

      results_q
    end

    def build_project_query(relation, query_params, params_y, skip_cursor: false)
      cursor_params = {
        limit: MAX_RESULTS_PER_PAGE
      }

      results_q = if query_params[:q].present?
        relation.text_search(query_params[:q])
      else
        Project.public_and_not_forked
      end

      # fetching the tags and author in the same query to avoid N+1 query problem
      # ordering the project results by number of views in descending order to get the most popular projects first
      results_q = results_q.order(view: :desc).includes(:tags, :author)

      unless skip_cursor
        cursor_params[:after] = params_y[:after]
        cursor_params[:before] = params_y[:before]
      end
      results_q = results_q.cursor_paginate(**cursor_params)
      results_q
    end
  end
end
