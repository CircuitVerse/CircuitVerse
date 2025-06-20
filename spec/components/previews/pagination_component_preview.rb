# frozen_string_literal: true

class PaginationComponentPreview < ViewComponent::Preview
  def with_results
    render(SearchComponents::PaginationComponent.new(results: mock_paginated_results))
  end

  private

    def mock_paginated_results
      results = []
      results.define_singleton_method(:empty?) { false }
      results.define_singleton_method(:current_page) { 2 }
      results.define_singleton_method(:total_pages) { 5 }
      results.define_singleton_method(:per_page) { 10 }
      results.define_singleton_method(:total_entries) { 45 }
      results.define_singleton_method(:previous_page) { 1 }
      results.define_singleton_method(:next_page) { 3 }
      results
    end
end
