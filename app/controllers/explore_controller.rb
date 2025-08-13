# frozen_string_literal: true

class ExploreController < ApplicationController
  def index
    return not_found unless Flipper.enabled?(:circuit_explore_page, current_user)

    svc = ExploreService.new(current_user: current_user, params: params)

    @circuit_of_the_week = svc.circuit_of_the_week
    @featured_examples   = svc.featured_examples
    @editor_picks        = svc.editor_picks
    @recent_projects     = svc.recent_projects
    @popular_tags        = svc.popular_tags

    respond_to do |format|
      format.html
    end
  end
end
