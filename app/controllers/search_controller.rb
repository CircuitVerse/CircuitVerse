# frozen_string_literal: true

class SearchController < ApplicationController
  skip_after_action :verify_authorized

  include SearchHelper

  PER_PAGE = 9

  def search
    resource = params[:resource]
    query_params = params

    results, template = query(resource, query_params)

    if template.present?
      @pagy, @results = pagy(results, limit: PER_PAGE)
      render template
    else
      not_found
    end
  end
end
