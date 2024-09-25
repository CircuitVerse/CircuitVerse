# frozen_string_literal: true

module LmsCredentialsModal
  class LmsCredentialsModalComponent < ViewComponent::Base
    def initialize(assignment, lms_integration_tutorial)
      super
      @assignment = assignment
      @lms_integration_tutorial = lms_integration_tutorial
    end
  end
end
