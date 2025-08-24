# frozen_string_literal: true

module Adapters
  class PgAdapter < BaseAdapter
    MAX_RESULTS_PER_PAGE = 9

    # Mapping of sort fields to actual database columns
    SORT_MAPPINGS = {
      project: {
        "created_at" => :created_at,
        "view" => :view,
        "views" => :view,
        "stars" => :stars_count
      }.freeze,
      user: {
        "created_at" => :created_at,
        "join_date" => :created_at,
        "projects" => :projects_count,
        "total_circuits" => :projects_count
      }.freeze
    }.freeze

    def search_project(relation, query_params)
      perform_search(
        base_results: base_project_results(relation, query_params),
        query_params: query_params,
        type: :project,
        includes: %i[tags author]
      )
    end

    def search_user(relation, query_params)
      perform_search(
        base_results: base_user_results(relation, query_params),
        query_params: query_params,
        type: :user
      )
    end

    private

      def perform_search(base_results:, query_params:, type:, includes: nil)
        results = base_results
        results = results.includes(*includes) if includes
        results = apply_filters(results, query_params, type)
        results = apply_sorting(results, query_params, type)

        results.paginate(page: query_params[:page], per_page: MAX_RESULTS_PER_PAGE)
      end

      def base_project_results(relation, query_params)
        query_params[:q].present? ? relation.text_search(query_params[:q]) : Project.public_and_not_forked
      end

      def base_user_results(relation, query_params)
        query_params[:q].present? ? relation.text_search(query_params[:q]) : User.all
      end

      def apply_sorting(relation, query_params, type)
        sort_field = sanitize_sort_field(query_params[:sort_by], type)
        return relation unless sort_field

        sort_direction = query_params[:sort_direction] == "asc" ? :asc : :desc
        relation.order(sort_field => sort_direction)
      end

      def apply_filters(relation, query_params, type)
        case type
        when :project
          apply_project_filters(relation, query_params)
        when :user
          apply_user_filters(relation, query_params)
        else
          relation
        end
      end

      def sanitize_sort_field(sort_by, type)
        return nil if sort_by.blank?

        SORT_MAPPINGS.dig(type, sort_by)
      end

      def apply_project_filters(relation, query_params)
        return relation if query_params[:tag].blank?

        tags = extract_tags(query_params[:tag])
        return relation if tags.empty?

        relation.joins(:tags).where(tags: { name: tags }).distinct
      end

      def apply_user_filters(relation, query_params)
        relation = filter_by_country(relation, query_params[:country])
        filter_by_institute(relation, query_params[:institute])
      end

      def extract_tags(tag_param)
        tag_param.split(",").map(&:strip).compact_blank
      end

      def filter_by_country(relation, country_param)
        return relation if country_param.blank?

        country = country_param.strip
        return relation if country.blank?

        relation.where("LOWER(country) = LOWER(?)", country)
      end

      def filter_by_institute(relation, institute_param)
        return relation if institute_param.blank?

        institute = institute_param.strip
        return relation if institute.blank?

        relation.where("educational_institute ILIKE ?", "%#{institute}%")
      end
  end
end
