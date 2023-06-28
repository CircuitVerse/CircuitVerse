module Bugsnag::Utility
  # @api private
  class MetadataDelegate
    # nil is a valid metadata value, so we need a sentinel object so we can tell
    # if the value parameter has been provided
    NOT_PROVIDED = Object.new

    ##
    # Add values to metadata
    #
    # @overload add_metadata(metadata, section, data)
    #   Merges data into the given section of metadata
    #   @param metadata [Hash] The metadata hash to operate on
    #   @param section [String, Symbol]
    #   @param data [Hash]
    #
    # @overload add_metadata(metadata, section, key, value)
    #   Sets key to value in the given section of metadata. If the value is nil
    #   the key will be deleted
    #   @param metadata [Hash] The metadata hash to operate on
    #   @param section [String, Symbol]
    #   @param key [String, Symbol]
    #   @param value
    #
    # @return [void]
    def add_metadata(metadata, section, key_or_data, value = NOT_PROVIDED)
      case value
      when NOT_PROVIDED
        merge_metadata(metadata, section, key_or_data)
      when nil
        clear_metadata(metadata, section, key_or_data)
      else
        overwrite_metadata(metadata, section, key_or_data, value)
      end
    end

    ##
    # Clear values from metadata
    #
    # @overload clear_metadata(metadata, section)
    #   Clears the given section of metadata
    #   @param metadata [Hash] The metadata hash to operate on
    #   @param section [String, Symbol]
    #
    # @overload clear_metadata(metadata, section, key)
    #   Clears the key in the given section of metadata
    #   @param metadata [Hash] The metadata hash to operate on
    #   @param section [String, Symbol]
    #   @param key [String, Symbol]
    #
    # @return [void]
    def clear_metadata(metadata, section, key = nil)
      if key.nil?
        metadata.delete(section)
      elsif metadata[section]
        metadata[section].delete(key)
      end
    end

    private

    ##
    # Merge new metadata into the existing metadata
    #
    # Any keys with a 'nil' value in the new metadata will be deleted from the
    # existing metadata
    #
    # @param existing_metadata [Hash]
    # @param section [String, Symbol]
    # @param new_metadata [Hash]
    # @return [void]
    def merge_metadata(existing_metadata, section, new_metadata)
      return unless new_metadata.is_a?(Hash)

      existing_metadata[section] ||= {}
      data = existing_metadata[section]

      new_metadata.each do |key, value|
        if value.nil?
          data.delete(key)
        else
          data[key] = value
        end
      end
    end

    ##
    # Overwrite the value in metadata's section & key
    #
    # @param metadata [Hash]
    # @param section [String, Symbol]
    # @param key [String, Symbol]
    # @param value
    # @return [void]
    def overwrite_metadata(metadata, section, key, value)
      return unless key.is_a?(String) || key.is_a?(Symbol)

      metadata[section] ||= {}
      metadata[section][key] = value
    end
  end
end
