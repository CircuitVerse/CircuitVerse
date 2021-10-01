# encoding: utf-8
# This file is distributed under New Relic's license terms.
# See https://github.com/newrelic/newrelic-ruby-agent/blob/main/LICENSE for complete details.

module NewRelic
  module Agent
    module AttributeProcessing
      module_function

      EMPTY_HASH_STRING_LITERAL = "{}".freeze
      EMPTY_ARRAY_STRING_LITERAL = "[]".freeze

      def flatten_and_coerce(object, prefix = nil, result = {}, &blk)
        if object.is_a? Hash
          flatten_and_coerce_hash(object, prefix, result, &blk)
        elsif object.is_a? Array
          flatten_and_coerce_array(object, prefix, result, &blk)
        elsif prefix
          val = Coerce.scalar(object)
          if blk
            blk.call(prefix, val)
          elsif !val.nil?
            result[prefix] = val
          end
        else
          NewRelic::Agent.logger.warn "Unexpected object: #{object.inspect} with nil prefix passed to NewRelic::Agent::AttributeProcessing.flatten_and_coerce"
        end
        result
      end

      def flatten_and_coerce_hash(hash, prefix, result, &blk)
        if hash.empty?
          if blk
            blk.call(prefix, EMPTY_HASH_STRING_LITERAL)
          else
            result[prefix] = EMPTY_HASH_STRING_LITERAL
          end
        else
          hash.each do |key, val|
            next_prefix = prefix ? "#{prefix}.#{key}" : key.to_s
            flatten_and_coerce(val, next_prefix, result, &blk)
          end
        end
      end

      def flatten_and_coerce_array(array, prefix, result, &blk)
        if array.empty?
          if blk
            blk.call(prefix, EMPTY_ARRAY_STRING_LITERAL)
          else
            result[prefix] = EMPTY_ARRAY_STRING_LITERAL
          end
        else
          array.each_with_index do |val, idx|
            next_prefix = prefix ? "#{prefix}.#{idx}" : idx.to_s
            flatten_and_coerce(val, next_prefix, result, &blk)
          end
        end
      end
    end
  end
end
