# frozen_string_literal: true

module ActiveRecordCursorPaginate
  # Represents a batch of records retrieved via a single iteration of
  # cursor-based pagination.
  #
  class Page
    # Records this page contains.
    # @return [Array<ActiveRecord::Base>]
    #
    attr_reader :records

    def initialize(records, order_columns:, has_previous: false, has_next: false, nullable_columns: nil)
      @records = records
      @order_columns = order_columns
      @has_previous = has_previous
      @has_next = has_next
      @nullable_columns = nullable_columns
    end

    # Number of records in this page.
    # @return [Integer]
    #
    def count
      records.size
    end

    # Whether this page is empty.
    # @return [Boolean]
    #
    def empty?
      count == 0
    end

    # Returns the cursor, which can be used to retrieve the next page.
    # @return [String]
    #
    def next_cursor
      cursor_for_record(records.last)
    end
    alias cursor next_cursor

    # Returns the cursor, which can be used to retrieve the previous page.
    # @return [String]
    #
    def previous_cursor
      cursor_for_record(records.first)
    end

    # Whether this page has a previous page.
    # @return [Boolean]
    #
    def has_previous?
      @has_previous
    end

    # Whether this page has a next page.
    # @return [Boolean]
    #
    def has_next?
      @has_next
    end

    # Returns cursor for a specific record.
    #
    # @param record [ActiveRecord::Base]
    # @return [String]
    #
    def cursor_for(record)
      cursor_for_record(record)
    end

    # Returns cursors for all the records on this page.
    # @return [Array<String>]
    #
    def cursors
      records.map { |record| cursor_for_record(record) }
    end

    private
      def cursor_for_record(record)
        if record
          cursor = Cursor.from_record(record, columns: @order_columns, nullable_columns: @nullable_columns)
          cursor.encode
        end
      end
  end
end
