# frozen_string_literal: true

module AssignmentForm
  class AssignmentFormComponent < ViewComponent::Base
    def initialize(assignment, group, current_user, lms_integration_tutorial)
      super
      @assignment = assignment
      @group = group
      @current_user = current_user
      @lms_integration_tutorial = lms_integration_tutorial
    end
  end
end
