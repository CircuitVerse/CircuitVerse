# frozen_string_literal: true

module SearchComponents
  class SearchBarComponent < ViewComponent::Base
    def initialize(resource: nil, query: nil)
      super
      @resource = resource
      @query = query
    end

    private

      attr_reader :resource, :query
  end
end
