# frozen_string_literal: true

module ProjectComponents
  class EditProjectFormComponent < ViewComponent::Base
    def initialize(project:, current_user:)
      super
      @project = project
      @current_user = current_user
    end
  end
end
