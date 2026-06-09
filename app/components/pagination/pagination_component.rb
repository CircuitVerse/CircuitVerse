# frozen_string_literal: true

module Pagination
  class PaginationComponent < ViewComponent::Base
    def initialize(collection:, **options)
      super()
      @collection = collection
      @options = options
    end

    private

      attr_reader :collection, :options
  end
end
