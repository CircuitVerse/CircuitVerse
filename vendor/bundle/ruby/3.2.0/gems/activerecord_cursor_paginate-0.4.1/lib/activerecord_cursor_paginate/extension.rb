# frozen_string_literal: true

module ActiveRecordCursorPaginate
  module Extension
    # Convenient method to use on ActiveRecord::Relation to get a paginator.
    # @return [ActiveRecordCursorPaginate::Paginator]
    # @see ActiveRecordCursorPaginate::Paginator#initialize
    #
    # @example
    #   paginator = Post.cursor_paginate(limit: 2, after: "Mg")
    #   page = paginator.fetch
    #
    def cursor_paginate(**options)
      Paginator.new(all, **options)
    end
    alias cursor_pagination cursor_paginate
  end
end
