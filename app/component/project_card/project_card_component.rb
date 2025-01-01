# frozen_string_literal: true

module ProjectCard
  class ProjectCardComponent < ViewComponent::Base
    include Pundit::Authorization
    include Devise::Controllers::Helpers

    def initialize(project, current_user)
      super
      @project = project
      @current_user = current_user
    end
  end
end
