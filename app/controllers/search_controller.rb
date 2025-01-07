# frozen_string_literal: true

class SearchController < ApplicationController
  include SearchHelper

  def search
    resource = params[:resource]
    query_params = params.permit(:cursor, :q, :resource, :button)

    @results, template, next_cursor, previous_cursor = query(resource, query_params)
    Rails.logger.info("Params received: #{params.inspect}")
    Rails.logger.info("Results received: #{@results}")
    Rails.logger.info("Cursor received in SearchController: #{params[:cursor]}")

    @next_cursor = next_cursor
    @previous_cursor = previous_cursor

    if template.present?
      render template
    else
      not_found
    end
  end
end
