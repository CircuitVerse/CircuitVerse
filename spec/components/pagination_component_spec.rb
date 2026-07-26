# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pagination::PaginationComponent, type: :component do
  let(:collection) do
    WillPaginate::Collection.create(2, 2, 5) do |pager|
      pager.replace(%w[third fourth])
    end
  end

  it "renders pagination for a paginated collection" do
    with_request_url "/search" do
      render_inline(described_class.new(collection: collection, renderer: PaginateRenderer))

      expect(page).to have_css(".pagination.justify-content-center")
      expect(page).to have_css(".page-item.active", text: "2")
    end
  end

  it "passes options to will_paginate" do
    with_request_url "/search" do
      render_inline(described_class.new(collection: collection,
                                        renderer: SearchPaginateRenderer,
                                        page_links: false))

      expect(page).to have_css(".pagination")
      expect(page).to have_css(".page-link", text: "Previous")
      expect(page).to have_css(".page-link", text: "Next")
      expect(page).to have_no_css(".page-item.active")
    end
  end
end
