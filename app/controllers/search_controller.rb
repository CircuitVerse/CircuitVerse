# frozen_string_literal: true

class SearchController < ApplicationController
  include SearchHelper

  def search
    resource = params[:resource]
    query_params = params

    if query_params[:q].blank?
      flash[:alert] = "Please enter a search term."
      redirect_to request.referer || root_path
      return
    end

    @results, template = query(resource, query_params)

    if template.present?
      render template
    else
      not_found
    end
  end
end
