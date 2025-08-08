# frozen_string_literal: true

module Adapters
  class PgAdapter < BaseAdapter
    MAX_RESULTS_PER_PAGE = 9

    def search_project(relation, query_params)
      results = if query_params[:q].present?
        relation.text_search(query_params[:q])
      else
        Project.public_and_not_forked
      end.includes(:tags, :author)

      # Apply sorting
      results = apply_project_sorting(results, query_params)

      results.paginate(page: query_params[:page], per_page: MAX_RESULTS_PER_PAGE)
    end

    def search_user(relation, query_params)
      results = if query_params[:q].present?
        relation.text_search(query_params[:q])
      else
        User.all
      end

      # Apply sorting
      results = apply_user_sorting(results, query_params)

      results.paginate(page: query_params[:page], per_page: MAX_RESULTS_PER_PAGE)
    end

    private

      def apply_project_sorting(relation, query_params)
        sort_by = query_params[:sort_by]
        sort_direction = query_params[:sort_direction] == "asc" ? :asc : :desc

        case sort_by
        when "created_at"
          relation.order(created_at: sort_direction)
        when "view", "views"
          relation.order(view: sort_direction)
        when "stars"
          relation.order(stars_count: sort_direction)
        else
          relation # No sorting applied
        end
      end

      def apply_user_sorting(relation, query_params)
        sort_by = query_params[:sort_by]
        sort_direction = query_params[:sort_direction] == "asc" ? :asc : :desc

        case sort_by
        when "created_at", "join_date"
          relation.order(created_at: sort_direction)
        when "projects", "total_circuits"
          relation.order(projects_count: sort_direction)
        else
          relation # No sorting applied
        end
      end
  end
end
