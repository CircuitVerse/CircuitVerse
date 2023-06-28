require 'uri'
require 'set'
require 'json'


module Bugsnag
  module Helpers # rubocop:todo Metrics/ModuleLength
    MAX_STRING_LENGTH = 3072
    MAX_PAYLOAD_LENGTH = 512000
    MAX_ARRAY_LENGTH = 80
    MAX_TRIM_STACK_FRAMES = 30
    RAW_DATA_TYPES = [Numeric, TrueClass, FalseClass]

    ##
    # Trim the size of value if the serialized JSON value is longer than is
    # accepted by Bugsnag
    def self.trim_if_needed(value)
      value = "" if value.nil?

      return value unless payload_too_long?(value)

      # Truncate exception messages
      reduced_value = truncate_exception_messages(value)
      return reduced_value unless payload_too_long?(reduced_value)

      # Trim metadata
      reduced_value = trim_metadata(reduced_value)
      return reduced_value unless payload_too_long?(reduced_value)

      # Trim code from stacktrace
      reduced_value = trim_stacktrace_code(reduced_value)
      return reduced_value unless payload_too_long?(reduced_value)

      # Remove metadata
      reduced_value = remove_metadata_from_events(reduced_value)
      return reduced_value unless payload_too_long?(reduced_value)

      # Remove oldest functions in stacktrace
      trim_stacktrace_functions(reduced_value)
    end

    ##
    # Merges r_hash into l_hash recursively, favouring the values in r_hash.
    #
    # Returns a new array consisting of the merged values
    def self.deep_merge(l_hash, r_hash)
      l_hash.merge(r_hash) do |key, l_val, r_val|
        if l_val.is_a?(Hash) && r_val.is_a?(Hash)
          deep_merge(l_val, r_val)
        elsif l_val.is_a?(Array) && r_val.is_a?(Array)
          l_val.concat(r_val)
        else
          r_val
        end
      end
    end

    ##
    # Merges r_hash into l_hash recursively, favouring the values in r_hash.
    #
    # Overwrites the values in the existing l_hash
    def self.deep_merge!(l_hash, r_hash)
      l_hash.merge!(r_hash) do |key, l_val, r_val|
        if l_val.is_a?(Hash) && r_val.is_a?(Hash)
          deep_merge(l_val, r_val)
        elsif l_val.is_a?(Array) && r_val.is_a?(Array)
          l_val.concat(r_val)
        else
          r_val
        end
      end
    end

    private

    TRUNCATION_INFO = '[TRUNCATED]'

    ##
    # Truncate exception messages
    def self.truncate_exception_messages(payload)
      extract_exception(payload) do |exception|
        exception[:message] = trim_as_string(exception[:message])
      end
      payload
    end

    ##
    # Remove all code from stacktraces
    def self.trim_stacktrace_code(payload)
      extract_exception(payload) do |exception|
        exception[:stacktrace].each do |frame|
          frame.delete(:code)
        end
      end
      payload
    end

    ##
    # Truncate stacktraces
    def self.trim_stacktrace_functions(payload)
      extract_exception(payload) do |exception|
        stack = exception[:stacktrace]
        exception[:stacktrace] = stack.take(MAX_TRIM_STACK_FRAMES)
      end
      payload
    end

    ##
    # Wrapper for trimming stacktraces
    def self.extract_exception(payload, &block)
      valid_payload = payload.is_a?(Hash) && payload[:events].respond_to?(:map)
      return unless valid_payload && block_given?
      payload[:events].each do |event|
        event[:exceptions].each(&block)
      end
    end

    ##
    # Take the metadata from the events and trim it down
    def self.trim_metadata(payload)
      return payload unless payload.is_a?(Hash) and payload[:events].respond_to?(:map)
      payload[:events].map do |event|
        event[:metaData] = truncate_arrays_in_value(event[:metaData])
        event[:metaData] = trim_strings_in_value(event[:metaData])
      end
      payload
    end

    ##
    # Check if a value is a raw type which should not be trimmed, truncated
    # or converted to a string
    def self.is_json_raw_type?(value)
      RAW_DATA_TYPES.detect {|klass| value.is_a?(klass)} != nil
    end

    ##
    # Shorten array until it fits within the payload size limit when serialized
    def self.truncate_array(array)
      return [] unless array.respond_to?(:slice)
      array.slice(0, MAX_ARRAY_LENGTH).map do |item|
        truncate_arrays_in_value(item)
      end
    end

    ##
    # Trim all strings to be less than the maximum allowed string length
    def self.trim_strings_in_value(value)
      return value if is_json_raw_type?(value)
      case value
      when Hash
        trim_strings_in_hash(value)
      when Array, Set
        trim_strings_in_array(value)
      else
        trim_as_string(value)
      end
    end

    ##
    # Validate that the serialized JSON string value is below maximum payload
    # length
    def self.payload_too_long?(value)
      get_payload_length(value) >= MAX_PAYLOAD_LENGTH
    end

    def self.get_payload_length(value)
      if value.is_a?(String)
        value.length
      else
        ::JSON.dump(value).length
      end
    end

    def self.trim_strings_in_hash(hash)
      return {} unless hash.is_a?(Hash)
      hash.each_with_object({}) do |(key, value), reduced_hash|
        if reduced_value = trim_strings_in_value(value)
          reduced_hash[key] = reduced_value
        end
      end
    end

    # If possible, convert the provided object to a string and trim to the
    # maximum allowed string length
    def self.trim_as_string(text)
      return "" unless text.respond_to? :to_s
      text = text.to_s
      if text.length > MAX_STRING_LENGTH
        length = MAX_STRING_LENGTH - TRUNCATION_INFO.length
        text = text.slice(0, length) + TRUNCATION_INFO
      end
      text
    end

    def self.trim_strings_in_array(collection)
      return [] unless collection.respond_to?(:map)
      collection.map {|value| trim_strings_in_value(value)}
    end

    def self.truncate_arrays_in_value(value)
      case value
      when Hash
        truncate_arrays_in_hash(value)
      when Array, Set
        truncate_array(value)
      else
        value
      end
    end

    # Remove `metaData` from array of `events` within object
    def self.remove_metadata_from_events(object)
      return {} unless object.is_a?(Hash) and object[:events].respond_to?(:map)
      object[:events].map do |event|
        event.delete(:metaData) if object.is_a?(Hash)
      end
      object
    end

    def self.truncate_arrays_in_hash(hash)
      return {} unless hash.is_a?(Hash)
      hash.each_with_object({}) do |(key, value), reduced_hash|
        if reduced_value = truncate_arrays_in_value(value)
          reduced_hash[key] = reduced_value
        end
      end
    end
  end
end
