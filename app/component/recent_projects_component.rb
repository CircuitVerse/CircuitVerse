# frozen_string_literal: true

class RecentProjectsComponent < ViewComponent::Base
    def initialize(projects:, projects_page:)
      @projects = projects
      @projects_page = projects_page
    end
  end
  
