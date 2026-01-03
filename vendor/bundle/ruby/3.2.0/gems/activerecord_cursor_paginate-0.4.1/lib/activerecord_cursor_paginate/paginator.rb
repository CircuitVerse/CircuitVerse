# frozen_string_literal: true

module ActiveRecordCursorPaginate
  # Use this Paginator class to effortlessly paginate through ActiveRecord
  # relations using cursor pagination.
  #
  # @example Iterating one page at a time
  #     ActiveRecordCursorPaginate::Paginator
  #       .new(relation, order: :author, limit: 2, after: "WyJKYW5lIiw0XQ")
  #       .fetch
  #
  # @example Iterating over the whole relation
  #     paginator = ActiveRecordCursorPaginate::Paginator
  #                   .new(relation, order: :author, limit: 2, after: "WyJKYW5lIiw0XQ")
  #
  #     # Will lazily iterate over the pages.
  #     paginator.pages.each do |page|
  #       # do something with the page
  #     end
  #
  class Paginator
    attr_reader :relation, :before, :after, :limit, :order, :append_primary_key
    attr_accessor :forward_pagination

    # Create a new instance of the `ActiveRecordCursorPaginate::Paginator`
    #
    # @param relation [ActiveRecord::Relation] Relation that will be paginated.
    # @param before [String, nil] Cursor to paginate upto (excluding).
    # @param after [String, nil] Cursor to paginate forward from.
    # @param limit [Integer, nil] Number of records to return in pagination.
    # @param order [Symbol, String, nil, Array<Symbol, String>, Hash]
    #   Column(s) to order by, optionally with directions (either `:asc` or `:desc`,
    #   defaults to `:asc`). If none is provided, will default to ID column.
    #   NOTE: this will cause the query to filter on both the given column as
    #   well as the ID column. So you might want to add a compound index to your
    #   database similar to:
    #   ```sql
    #     CREATE INDEX <index_name> ON <table_name> (<order_fields>..., id)
    #   ```
    # @param append_primary_key [Boolean] (true). Specifies whether the primary column(s)
    #   should be implicitly appended to the list of sorting columns. It may be useful
    #   to disable it for the table with a UUID primary key or when the sorting is done by a
    #   combination of columns that are already unique.
    # @param nullable_columns [Symbol, String, nil, Array] Columns which are nullable.
    #   By default, all columns are considered as non-nullable, if not in this list.
    #   It is not recommended to use this feature, because the complexity of produced SQL
    #   queries can have a very negative impact on the database performance. It is better
    #   to paginate using only non-nullable columns.
    # @param forward_pagination [Boolean] Whether this is a forward or backward pagination.
    #   Optional, defaults to `true` if `:before` is not provided, `false` otherwise.
    #   Useful when paginating backward from the end of the collection.
    #
    # @raise [ArgumentError] If any parameter is not valid
    #
    def initialize(relation, before: nil, after: nil, limit: nil, order: nil, append_primary_key: true,
                   nullable_columns: nil, forward_pagination: before.nil?)
      unless relation.is_a?(ActiveRecord::Relation)
        raise ArgumentError, "relation is not an ActiveRecord::Relation"
      end

      @relation = relation
      @primary_key = @relation.primary_key
      @append_primary_key = append_primary_key

      @cursor = @current_cursor = nil
      @forward_pagination = forward_pagination
      @before = @after = nil
      @page_size = nil
      @limit = nil
      @columns = []
      @directions = []
      @order = nil

      self.before = before
      self.after = after
      self.limit = limit
      self.order = order
      self.nullable_columns = nullable_columns
    end

    def before=(value)
      if value.present? && after.present?
        raise ArgumentError, "Only one of :before and :after can be provided"
      end

      @cursor = value || after
      @current_cursor = @cursor
      @forward_pagination = false if value
      @before = value
    end

    def after=(value)
      if value.present? && before.present?
        raise ArgumentError, "Only one of :before and :after can be provided"
      end

      @cursor = value || before
      @current_cursor = @cursor
      @forward_pagination = true if value
      @after = value
    end

    def limit=(value)
      config = ActiveRecordCursorPaginate.config
      @page_size = value || config.default_page_size
      @page_size = [@page_size, config.max_page_size].min if config.max_page_size
      @limit = @page_size
    end

    def order=(value)
      order = normalize_order(value)
      @columns = order.keys
      @directions = order.values
      @order = value
    end

    def nullable_columns=(value)
      value = Array.wrap(value)
      value = value.map { |column| column.is_a?(Symbol) ? column.to_s : column }

      if (value - @columns).any?
        raise ArgumentError, ":nullable_columns should include only column names from the :order option"
      end

      if value.include?(@columns.last)
        raise ArgumentError, "Last order column can not be nullable"
      end

      @nullable_columns = value
    end

    # Get the paginated result.
    # @return [ActiveRecordCursorPaginate::Page]
    #
    # @note Calling this method advances the paginator.
    #
    def fetch
      relation = build_cursor_relation(@current_cursor)

      relation = relation.limit(@page_size + 1)
      records_plus_one = relation.to_a
      has_additional = records_plus_one.size > @page_size

      records = records_plus_one.take(@page_size)
      records.reverse! unless @forward_pagination

      if @forward_pagination
        has_next_page = has_additional
        has_previous_page = @current_cursor.present?
      else
        has_next_page = @current_cursor.present?
        has_previous_page = has_additional
      end

      page = Page.new(
        records,
        order_columns: cursor_column_names,
        has_next: has_next_page,
        has_previous: has_previous_page,
        nullable_columns: nullable_cursor_column_names
      )

      advance_by_page(page) unless page.empty?

      page
    end
    alias page fetch

    # Returns an enumerator that can be used to iterate over the whole relation.
    # @return [Enumerator]
    #
    def pages
      Enumerator.new do |yielder|
        loop do
          page = fetch
          break if page.empty?

          yielder.yield(page)
        end
      end
    end

    # Total number of records to iterate by this paginator.
    # @return [Integer]
    #
    def total_count
      @total_count ||= @relation.count(:all)
    end

    private
      def normalize_order(order)
        order ||= {}
        default_direction = :asc

        result =
          case order
          when String, Symbol
            { order => default_direction }
          when Hash
            order
          when Array
            order.to_h { |column| [column, default_direction] }
          else
            raise ArgumentError, "Invalid order: #{order.inspect}"
          end

        result = result.with_indifferent_access
        result.transform_values! { |direction| direction.downcase.to_sym }

        if @append_primary_key
          Array(@primary_key).each { |column| result[column] ||= default_direction }
        end

        raise ArgumentError, ":order must contain columns to order by" if result.blank?

        result
      end

      def build_cursor_relation(cursor)
        relation = @relation

        # Non trivial columns (expressions or joined tables columns).
        if @columns.any?(/\W/)
          arel_columns = @columns.map.with_index do |column, i|
            arel_column(column).as("cursor_column_#{i + 1}")
          end

          relation =
            if relation.select_values.empty?
              relation.select(relation.arel_table[Arel.star], arel_columns)
            else
              relation.select(arel_columns)
            end
        end

        pagination_directions = @directions.map { |direction| pagination_direction(direction) }
        relation = relation.reorder(@columns.zip(pagination_directions).to_h)

        if cursor
          decoded_cursor = Cursor.decode(cursor_string: cursor, columns: cursor_column_names, nullable_columns: nullable_cursor_column_names)
          relation = apply_cursor(relation, decoded_cursor)
        end

        relation
      end

      def nullable_cursor_column_names
        @nullable_columns.map do |column|
          cursor_column_names[@columns.index(column)]
        end
      end

      def cursor_column_names
        if @columns.any?(/\W/)
          @columns.size.times.map { |i| "cursor_column_#{i + 1}" }
        else
          @columns
        end
      end

      def apply_cursor(relation, cursor)
        cursor_positions = @columns.zip(cursor.values, @directions)

        where_clause = nil

        cursor_positions.reverse_each.with_index do |(column, value, direction), index|
          previous_where_clause = where_clause

          operator = pagination_operator(direction)
          arel_column = arel_column(column)

          # The last column can't be nil.
          if index == 0
            where_clause = arel_column.public_send(operator, value)
          elsif value.nil?
            if nulls_at_end?(direction)
              # We are at the section with nulls, which is at the end ([x, x, null, null, null])
              where_clause = arel_column.eq(nil).and(previous_where_clause)
            else
              # We are at the section with nulls, which is at the beginning ([null, null, null, x, x])
              where_clause = arel_column.not_eq(nil)
              where_clause = arel_column.eq(nil).and(previous_where_clause).or(where_clause)
            end
          else
            where_clause = arel_column.public_send(operator, value).or(
              arel_column.eq(value).and(previous_where_clause)
            )

            if nullable_column?(column) && nulls_at_end?(direction)
              # Since column's value is not null, nulls can only be at the end.
              where_clause = arel_column.eq(nil).or(where_clause)
            end
          end
        end

        relation.where(where_clause)
      end

      def arel_column(column)
        if Arel.arel_node?(column)
          column
        elsif column.match?(/\A\w+\.\w+\z/)
          Arel.sql(column)
        else
          @relation.arel_table[column]
        end
      end

      def pagination_direction(direction)
        if @forward_pagination
          direction
        else
          direction == :asc ? :desc : :asc
        end
      end

      def pagination_operator(direction)
        if @forward_pagination
          direction == :asc ? :gt : :lt
        else
          direction == :asc ? :lt : :gt
        end
      end

      def advance_by_page(page)
        @current_cursor =
          if @forward_pagination
            page.next_cursor
          else
            page.previous_cursor
          end
      end

      def nulls_at_end?(direction)
        (direction == :asc && !small_nulls?) || (direction == :desc && small_nulls?)
      end

      def small_nulls?
        # PostgreSQL considers NULLs larger than any value,
        # opposite for SQLite and MySQL.
        db_config = @relation.klass.connection_pool.db_config
        db_config.adapter !~ /postg/ # postgres and postgis
      end

      def nullable_column?(column)
        @nullable_columns.include?(column)
      end
  end
end
