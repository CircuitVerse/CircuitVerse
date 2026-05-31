# frozen_string_literal: true

class ProjectEmbedComponent < ViewComponent::Base
  def initialize(project)
    super()
    @project = project
  end
end
