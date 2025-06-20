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
    before do
      allow_any_instance_of(ActionView::Base).to receive(:will_paginate)
        .and_return('<div class="pagination">Mock pagination</div>'.html_safe)
    end

    it "renders pagination" do
      paginated_results = WillPaginate::Collection.create(1, 5, 10) do |pager|
        pager.replace([1, 2, 3, 4, 5])
      end

      render_inline(described_class.new(results: paginated_results))
      expect(rendered_content).to include("Mock pagination")
    end
  end
end
