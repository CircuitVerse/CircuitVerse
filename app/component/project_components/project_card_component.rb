# frozen_string_literal: true

module ProjectComponents
  class ProjectCardComponent < ViewComponent::Base
    include UsersCircuitverseHelper

    def initialize(project:)
      super
      @project = project
    end

    private

      attr_reader :project
  end
end
