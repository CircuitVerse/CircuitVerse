module Playwright
  class Channel
    include EventEmitter

    # @param connection [Playwright::Connection]
    # @param guid [String]
    # @param object [Playwright::ChannelOwner]
    def initialize(connection, guid, object:)
      @connection = connection
      @guid = guid
      @object = object
    end

    attr_reader :guid, :object

    # @param method [String]
    # @param params [Hash]
    # @return [Playwright::ChannelOwner|nil]
    def send_message_to_server(method, params = {})
      result = send_message_to_server_result(method, params)
      if result.is_a?(Hash)
        _type, channel_owner = result.first
        channel_owner
      else
        nil
      end
    end

    # @param method [String]
    # @param params [Hash]
    # @return [Hash]
    def send_message_to_server_result(title = nil, method, params)
      check_not_collected
      with_logging(title) do |metadata|
        @connection.send_message_to_server(@guid, method, params, metadata: metadata)
      end
    end

    # @param method [String]
    # @param params [Hash]
    # @returns [Concurrent::Promises::Future]
    def async_send_message_to_server(method, params = {})
      check_not_collected
      with_logging do |metadata|
        @connection.async_send_message_to_server(@guid, method, params, metadata: metadata)
      end
    end

    private def with_logging(title = nil, &block)
      locations = caller_locations
      first_api_call_location_idx = locations.index { |loc| loc.absolute_path&.include?('playwright_api') }
      unless first_api_call_location_idx
        return block.call(nil)
      end

      locations = locations.slice(first_api_call_location_idx..-1)

      api_call_location = locations.shift

      api_class = File.basename(api_call_location.absolute_path, '.rb')
      api_method = api_call_location.label
      api_name = "#{api_class}##{api_method}"

      stacks = locations

      metadata = build_metadata_payload_from(api_name, stacks)
      if title
        metadata[:title] = title
      end
      block.call(metadata)
    end

    private def build_metadata_payload_from(api_name, stacks)
      {
        wallTime: (Time.now.to_f * 1000).to_i,
        apiName: api_name,
        stack: stacks.map do |loc|
          { file: loc.absolute_path || '', line: loc.lineno, function: loc.label }
        end,
      }
    end

    private def check_not_collected
      if @object.was_collected?
        raise "The object has been collected to prevent unbounded heap growth."
      end
    end
  end
end
