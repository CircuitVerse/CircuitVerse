# frozen_string_literal: true

class ProjectEmbedComponent < ViewComponent::Base
  # @param [Project] project
  def initialize(project)
    super
    @project = project
  end
end
