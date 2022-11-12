# frozen_string_literal: true

module ActiveRecord
  class PredicateBuilder
    class PolymorphicArrayValue # :nodoc:
      def initialize(associated_table, values)
        @associated_table = associated_table
        @values = values
      end

      def queries
        return [ associated_table.join_foreign_key => values ] if values.empty?

        type_to_ids_mapping.map do |type, ids|
          query = {}
          query[associated_table.join_foreign_type] = type if type
          query[associated_table.join_foreign_key] = ids
          query
        end
      end

      private
        attr_reader :associated_table, :values

        def type_to_ids_mapping
          default_hash = Hash.new { |hsh, key| hsh[key] = [] }
          values.each_with_object(default_hash) do |value, hash|
            hash[klass(value)&.polymorphic_name] << convert_to_id(value)
          end
        end

        def primary_key(value)
          associated_table.join_primary_key(klass(value))
        end

        def klass(value)
          case value
          when Base
            value.class
          when Relation
            value.klass
          end
        end

        def convert_to_id(value)
          case value
          when Base
            value._read_attribute(primary_key(value))
          when Relation
            value.select(primary_key(value))
          else
            value
          end
        end
    end
  end
end
