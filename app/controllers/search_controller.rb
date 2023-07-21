# frozen_string_literal: true

class SearchController < ApplicationController
  include SearchHelper

  before_action :reload_model

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

  private

    def reload_model
      Rails.application.reloader.reload!
    end
end
