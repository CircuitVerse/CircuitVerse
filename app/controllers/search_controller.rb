# frozen_string_literal: true

class SearchController < ApplicationController
  include SearchHelper

  def search
    resource = params[:resource]
    query_params = params

    @results, template = query(resource, query_params)

    if template.present?
      render template
    else
      not_found
    end
  end
end
