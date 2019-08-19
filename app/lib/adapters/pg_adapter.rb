# frozen_string_literal: true

module Adapters
  class PgAdapter < BaseAdapter
    MAX_RESULTS_PER_PAGE = 5

    def search_project(relation, query_params)
      if query_params[:q].present?
        relation.text_search(query_params[:q])
      else
        Project.public_and_not_forked
      end.includes(:tags, :author)
        .paginate(page: query_params[:page], per_page: MAX_RESULTS_PER_PAGE)
    end

    def search_user(relation, query_params)
      if query_params[:q].present?
        relation.text_search(query_params[:q])
      else
        User.all
      end.paginate(page: query_params[:page], per_page: MAX_RESULTS_PER_PAGE)
    end
  end
end
