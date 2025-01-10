# frozen_string_literal: true

class SearchController < ApplicationController
  include SearchHelper

  def search
    resource = params[:resource]
    query_params = params.permit(:q, :resource, :button)
    params_y = {}
    params_y[:after] = params[:after]
    params_y[:before] = params[:before]
    # passing the params as params_y to the query method along with the query_params
    # this is done to pass the pagination params to the query method
    @results, template = query(resource, query_params, params_y)

    if template.present?
      render template
    else
      not_found
    end
  end
end
