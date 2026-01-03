module Lookbook
  # Set of helpers for preview layouts
  #
  # @api public
  module PreviewHelper
    def lookbook_display(key, fallback = nil)
      params.dig(:lookbook, :display, key.to_sym) || fallback
    end

    def lookbook_data(key, fallback = nil)
      Lookbook.data.fetch(key.to_sym, fallback)
    end
  end
end
