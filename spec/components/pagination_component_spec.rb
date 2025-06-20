# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchComponents::PaginationComponent, type: :component do
  include ViewComponent::TestHelpers

  context "when results are empty" do
    it "does not render pagination" do
      empty_results = []
      render_inline(described_class.new(results: empty_results))
      expect(rendered_content).to be_blank
    end
  end

  context "when results have content" do
    it "renders pagination" do
      paginated_results = WillPaginate::Collection.create(2, 5, 15) do |pager|
        pager.replace([1, 2, 3, 4, 5])
      end

      component = described_class.new(results: paginated_results)

      allow(component).to receive(:will_paginate)
        .with(paginated_results, renderer: SearchPaginateRenderer, page_links: false)
        .and_return('<div class="pagination">Page 2 of 3</div>'.html_safe)

      render_inline(component)
      expect(rendered_content).to include("Page 2 of 3")
    end
  end
end
