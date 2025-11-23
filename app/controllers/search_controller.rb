# frozen_string_literal: true

class SearchController < ApplicationController
  include SearchHelper

  def search
    resource = params[:resource]
    query_params = params

    #If no query param is given, show message instead of 404
    if query_params[:q].blank?
      @results = []
      flash.now[:notice] = "Please enter a search term."
      render :search_results and return
    end

    @results, template = query(resource, query_params)

    if template.present?
      render template
    else
      #If template not found, fallback to a generic results view with message
      @results ||= []
      flash.now[:alert] = "Search results could not be displayed."
      render :search_resutls,status: :ok
    end
  end
end
