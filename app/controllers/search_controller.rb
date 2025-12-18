# frozen_string_literal: true

class SearchController < ApplicationController
  include SearchHelper

  def search
    resource = params[:resource]
    query_params = params

    # If no query param is given, show message instead of 404
    if query_params[:q].blank?
      @results = []
      render :search_results and return
    end

    @results, template = query(resource, query_params)

    # non-existent resource → not_found (OLD behavior)
    if template.present?
      render template
    else
      not_found
    end
  end
end
