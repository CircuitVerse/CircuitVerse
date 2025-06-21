# frozen_string_literal: true

class SearchController < ApplicationController
  include SearchHelper

  def search
    resource = params[:resource]
    query_params = params

    page = query_params[:page].to_i
    page = 1 if page < 1
    query_params[:page] = page

    @results, template = query(resource, query_params)

    if template.present?
      render template
    else
      not_found
    end
  end
end
