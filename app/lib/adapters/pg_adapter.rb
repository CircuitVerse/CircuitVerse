# frozen_string_literal: true

module Adapters
  class PgAdapter < BaseAdapter
    MAX_RESULTS_PER_PAGE = 9

    def search_project(relation, query_params)
      results = if query_params[:q].present?
      results = if query_params[:q].present?
        relation.text_search(query_params[:q])
      else
        Project.public_and_not_forked
      end.includes(:tags, :author)

      # Apply filters
      results = apply_project_filters(results, query_params)

      # Apply sorting
      results = apply_project_sorting(results, query_params)

      results.paginate(page: query_params[:page], per_page: MAX_RESULTS_PER_PAGE)
    end

    def search_user(relation, query_params)
      results = if query_params[:q].present?
      results = if query_params[:q].present?
        relation.text_search(query_params[:q])
      else
        User.all
      end

      # Apply filters
      results = apply_user_filters(results, query_params)

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

      def apply_project_filters(relation, query_params)
        # Filter by tags if provided
        if query_params[:tag].present?
          tags = query_params[:tag].split(',').map(&:strip).reject(&:blank?)
          if tags.any?
            # Use OR logic - projects that have ANY of the specified tags
            relation = relation.joins(:tags).where(tags: { name: tags }).distinct
          end
        end

        relation
      end

      def apply_user_filters(relation, query_params)
        # Filter by country if provided
        if query_params[:country].present?
          country = query_params[:country].strip
          relation = relation.where("LOWER(country) = LOWER(?)", country) if country.present?
        end

        # Filter by educational institute if provided
        if query_params[:institute].present?
          institute = query_params[:institute].strip
          # Use ILIKE for partial matching on institute names
          relation = relation.where("educational_institute ILIKE ?", "%#{institute}%") if institute.present?
        end

        relation
      end
  end
end
