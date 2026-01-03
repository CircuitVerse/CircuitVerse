# frozen_string_literal: true

module ActiveRecordCursorPaginate
  class Config
    attr_accessor :default_page_size, :max_page_size

    def initialize
      @default_page_size = 10
    end
  end
end
