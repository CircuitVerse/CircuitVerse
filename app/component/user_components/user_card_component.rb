# frozen_string_literal: true

module UserComponents
  class UserCardComponent < ViewComponent::Base
    include UsersCircuitverseHelper

    def initialize(profile:)
      super
      @profile = profile
    end

    private

      attr_reader :profile
  end
end
