# frozen_string_literal: true

class Project::ProjectCardComponent < ViewComponent::Base
  include UsersCircuitverseHelper

  def initialize(project:)
    super
    @project = project
  end

  private

    attr_reader :project
end
