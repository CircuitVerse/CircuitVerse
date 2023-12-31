# frozen_string_literal: true

module ProjectComponents
  class AddCollaboratorModalComponent < ViewComponent::Base
    def initialize(collaboration:)
      super
      @collaboration = collaboration
    end
  end
end
