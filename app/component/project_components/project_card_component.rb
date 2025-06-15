# frozen_string_literal: true

module ProjectComponents
  class ProjectCardComponent < ViewComponent::Base
    include UsersCircuitverseHelper

    def initialize(project:, current_user: nil)
      super
      @project = project
      @current_user = current_user
    end

    private

      attr_reader :project, :current_user
  end
end
