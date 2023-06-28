class Commontator::Collection < WillPaginate::Collection
  attr_reader :root_per_page

  # This method determines if we are in a shorter version of the first page, which we call page 0
  def page_zero?
    total_entries > @per_page && @per_page < @root_per_page
  end

  def initialize(array, count, root_per_page, per_page, page = 1)
    self.total_entries = count
    @root_per_page = root_per_page
    @per_page = per_page
    @current_page = page_zero? ? 0 : WillPaginate::PageNumber(page)
    @first_call = true

    replace(array)
  end

  # We return 2 total_pages under certain conditions to trick will_paginate
  # into rendering the pagination controls when it otherwise wouldn't
  def total_pages
    min_total_pages = page_zero? && @first_call ? 2 : 1
    @first_call = false
    [ (total_entries.to_f/@root_per_page).ceil, min_total_pages ].max
  end
end
