# frozen_string_literal: true

module Adapters
  class BaseAdapter
    protected

      def sanitize_page(page)
        page_num = page.to_i
        page_num.positive? ? page_num : 1
      end
  end
end
