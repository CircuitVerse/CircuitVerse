# frozen_string_literal: true

# https://github.com/rails/rails/issues/54260
require "logger"

require "active_record"

require_relative "activerecord_cursor_paginate/version"
require_relative "activerecord_cursor_paginate/cursor"
require_relative "activerecord_cursor_paginate/page"
require_relative "activerecord_cursor_paginate/paginator"
require_relative "activerecord_cursor_paginate/extension"
require_relative "activerecord_cursor_paginate/config"

module ActiveRecordCursorPaginate
  class Error < StandardError; end

  # Error that gets raised if a cursor given as `before` or `after` cannot be
  # properly parsed.
  class InvalidCursorError < Error; end

  class << self
    def configure
      yield config
    end

    def config
      @config ||= Config.new
    end
  end
end

ActiveSupport.on_load(:active_record) do
  extend ActiveRecordCursorPaginate::Extension
end
