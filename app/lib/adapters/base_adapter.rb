# frozen_string_literal: true

module Adapters
  class BaseAdapter
    protected

      # Coerces an arbitrary page param into a safe, positive integer.
      #
      # will_paginate calls Integer() on the page value, so a non-numeric
      # string (e.g. a SQL-injection probe) raises ArgumentError. This
      # normalises nil, blank, non-numeric, array and non-positive values
      # to page 1 without ever raising.
      def sanitize_page(page)
        page_num = Integer(page.to_s, 10, exception: false)
        page_num&.positive? ? page_num : 1
      end
  end
end
