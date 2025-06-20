# frozen_string_literal: true

module SearchComponents
  class PaginationComponent < ViewComponent::Base
    def initialize(results:)
      super
      @results = results
    end
  end
end
