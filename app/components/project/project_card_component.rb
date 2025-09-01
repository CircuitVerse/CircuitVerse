# frozen_string_literal: true

class Project::ProjectCardComponent < ViewComponent::Base
  include UsersCircuitverseHelper

  with_collection_parameter :project

  def initialize(project:)
    super()
    @project = project
  end

  private

    attr_reader :project
end
