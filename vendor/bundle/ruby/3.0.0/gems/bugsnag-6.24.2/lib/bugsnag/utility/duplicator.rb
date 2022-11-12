module Bugsnag::Utility
  # @api private
  class Duplicator
    class << self
      ##
      # Duplicate (deep clone) the given object
      #
      # @param object [Object]
      # @param seen_objects [Hash<String, Object>]
      # @return [Object]
      def duplicate(object, seen_objects = {})
        case object
        # return immutable & non-duplicatable objects as-is
        when Symbol, Numeric, Method, TrueClass, FalseClass, NilClass
          object
        when Array
          duplicate_array(object, seen_objects)
        when Hash
          duplicate_hash(object, seen_objects)
        when Range
          duplicate_range(object, seen_objects)
        when Struct
          duplicate_struct(object, seen_objects)
        else
          duplicate_generic_object(object, seen_objects)
        end
      rescue StandardError
        object
      end

      private

      def duplicate_array(array, seen_objects)
        id = array.object_id

        return seen_objects[id] if seen_objects.key?(id)

        copy = array.dup
        seen_objects[id] = copy

        copy.map! do |value|
          duplicate(value, seen_objects)
        end

        copy
      end

      def duplicate_hash(hash, seen_objects)
        id = hash.object_id

        return seen_objects[id] if seen_objects.key?(id)

        copy = {}
        seen_objects[id] = copy

        hash.each do |key, value|
          copy[duplicate(key, seen_objects)] = duplicate(value, seen_objects)
        end

        copy
      end

      ##
      # Ranges are immutable but the values they contain may not be
      #
      # For example, a range of "a".."z" can be mutated: range.first.upcase!
      def duplicate_range(range, seen_objects)
        id = range.object_id

        return seen_objects[id] if seen_objects.key?(id)

        begin
          copy = range.class.new(
            duplicate(range.first, seen_objects),
            duplicate(range.last, seen_objects),
            range.exclude_end?
          )
        rescue StandardError
          copy = range.dup
        end

        seen_objects[id] = copy
      end

      def duplicate_struct(struct, seen_objects)
        id = struct.object_id

        return seen_objects[id] if seen_objects.key?(id)

        copy = struct.dup
        seen_objects[id] = copy

        struct.each_pair do |attribute, value|
          begin
            copy.send("#{attribute}=", duplicate(value, seen_objects))
          rescue StandardError # rubocop:todo Lint/SuppressedException
          end
        end

        copy
      end

      def duplicate_generic_object(object, seen_objects)
        id = object.object_id

        return seen_objects[id] if seen_objects.key?(id)

        copy = object.dup
        seen_objects[id] = copy

        begin
          copy.instance_variables.each do |variable|
            value = copy.instance_variable_get(variable)

            copy.instance_variable_set(variable, duplicate(value, seen_objects))
          end
        rescue StandardError # rubocop:todo Lint/SuppressedException
        end

        copy
      end
    end
  end
end
