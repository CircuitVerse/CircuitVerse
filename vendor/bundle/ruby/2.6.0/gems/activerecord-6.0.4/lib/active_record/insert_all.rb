# frozen_string_literal: true

module ActiveRecord
  class InsertAll # :nodoc:
    attr_reader :model, :connection, :inserts, :keys
    attr_reader :on_duplicate, :returning, :unique_by

    def initialize(model, inserts, on_duplicate:, returning: nil, unique_by: nil)
      raise ArgumentError, "Empty list of attributes passed" if inserts.blank?

      @model, @connection, @inserts, @keys = model, model.connection, inserts, inserts.first.keys.map(&:to_s).to_set
      @on_duplicate, @returning, @unique_by = on_duplicate, returning, unique_by

      @returning = (connection.supports_insert_returning? ? primary_keys : false) if @returning.nil?
      @returning = false if @returning == []

      @unique_by = find_unique_index_for(unique_by) if unique_by
      @on_duplicate = :skip if @on_duplicate == :update && updatable_columns.empty?

      ensure_valid_options_for_connection!
    end

    def execute
      message = +"#{model} "
      message << "Bulk " if inserts.many?
      message << (on_duplicate == :update ? "Upsert" : "Insert")
      connection.exec_insert_all to_sql, message
    end

    def updatable_columns
      keys - readonly_columns - unique_by_columns
    end

    def primary_keys
      Array(model.primary_key)
    end


    def skip_duplicates?
      on_duplicate == :skip
    end

    def update_duplicates?
      on_duplicate == :update
    end

    def map_key_with_value
      inserts.map do |attributes|
        attributes = attributes.stringify_keys
        verify_attributes(attributes)

        keys.map do |key|
          yield key, attributes[key]
        end
      end
    end

    private
      def find_unique_index_for(unique_by)
        match = Array(unique_by).map(&:to_s)

        if index = unique_indexes.find { |i| match.include?(i.name) || i.columns == match }
          index
        else
          raise ArgumentError, "No unique index found for #{unique_by}"
        end
      end

      def unique_indexes
        connection.schema_cache.indexes(model.table_name).select(&:unique)
      end


      def ensure_valid_options_for_connection!
        if returning && !connection.supports_insert_returning?
          raise ArgumentError, "#{connection.class} does not support :returning"
        end

        if skip_duplicates? && !connection.supports_insert_on_duplicate_skip?
          raise ArgumentError, "#{connection.class} does not support skipping duplicates"
        end

        if update_duplicates? && !connection.supports_insert_on_duplicate_update?
          raise ArgumentError, "#{connection.class} does not support upsert"
        end

        if unique_by && !connection.supports_insert_conflict_target?
          raise ArgumentError, "#{connection.class} does not support :unique_by"
        end
      end


      def to_sql
        connection.build_insert_sql(ActiveRecord::InsertAll::Builder.new(self))
      end


      def readonly_columns
        primary_keys + model.readonly_attributes.to_a
      end

      def unique_by_columns
        Array(unique_by&.columns)
      end


      def verify_attributes(attributes)
        if keys != attributes.keys.to_set
          raise ArgumentError, "All objects being inserted must have the same keys"
        end
      end

      class Builder # :nodoc:
        attr_reader :model

        delegate :skip_duplicates?, :update_duplicates?, :keys, to: :insert_all

        def initialize(insert_all)
          @insert_all, @model, @connection = insert_all, insert_all.model, insert_all.connection
        end

        def into
          "INTO #{model.quoted_table_name} (#{columns_list})"
        end

        def values_list
          types = extract_types_from_columns_on(model.table_name, keys: keys)

          values_list = insert_all.map_key_with_value do |key, value|
            connection.with_yaml_fallback(types[key].serialize(value))
          end

          connection.visitor.compile(Arel::Nodes::ValuesList.new(values_list))
        end

        def returning
          format_columns(insert_all.returning) if insert_all.returning
        end

        def conflict_target
          if index = insert_all.unique_by
            sql = +"(#{format_columns(index.columns)})"
            sql << " WHERE #{index.where}" if index.where
            sql
          elsif update_duplicates?
            "(#{format_columns(insert_all.primary_keys)})"
          end
        end

        def updatable_columns
          quote_columns(insert_all.updatable_columns)
        end

        private
          attr_reader :connection, :insert_all

          def columns_list
            format_columns(insert_all.keys)
          end

          def extract_types_from_columns_on(table_name, keys:)
            columns = connection.schema_cache.columns_hash(table_name)

            unknown_column = (keys - columns.keys).first
            raise UnknownAttributeError.new(model.new, unknown_column) if unknown_column

            keys.index_with { |key| model.type_for_attribute(key) }
          end

          def format_columns(columns)
            columns.respond_to?(:map) ? quote_columns(columns).join(",") : columns
          end

          def quote_columns(columns)
            columns.map(&connection.method(:quote_column_name))
          end
      end
  end
end
