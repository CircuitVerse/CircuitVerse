# frozen_string_literal: true

module Playwright
  # https://github.com/microsoft/playwright/blob/master/src/client/connection.ts
  # https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_connection.py
  # https://github.com/microsoft/playwright-java/blob/master/playwright/src/main/java/com/microsoft/playwright/impl/Connection.java
  class Connection
    def initialize(transport)
      @transport = transport
      @transport.on_message_received do |message|
        dispatch(message)
      end
      @transport.on_driver_crashed do
        @callbacks.each_value do |callback|
          callback.reject(::Playwright::DriverCrashedError.new)
        end
        raise ::Playwright::DriverCrashedError.new
      end
      @transport.on_driver_closed do
        cleanup
      end

      @objects = {} # Hash[ guid => ChannelOwner ]
      @waiting_for_object = {} # Hash[ guid => Promise<ChannelOwner> ]
      @callbacks = {} # Hash [ guid => Promise<ChannelOwner> ]
      @root_object = RootChannelOwner.new(self)
      @remote = false
      @tracing_count = 0
      @closed_error = nil
    end

    attr_reader :local_utils

    def mark_as_remote
      @remote = true
    end

    def remote?
      @remote
    end

    def async_run
      @transport.async_run
    end

    def stop
      @transport.stop
      cleanup
    end

    def cleanup(cause: nil)
      @closed_error = TargetClosedError.new(message: cause)
      @callbacks.each_value do |callback|
        callback.reject(@closed_error)
      end
      @callbacks.clear
    end

    def initialize_playwright
      # Avoid Error: sdkLanguage: expected one of (javascript|python|java|csharp)
      # ref: https://github.com/microsoft/playwright/pull/18308
      # ref: https://github.com/YusukeIwaki/playwright-ruby-client/issues/228
      result = send_message_to_server('', 'initialize', { sdkLanguage: 'python' })
      ChannelOwners::Playwright.from(result['playwright'])
    end

    def set_in_tracing(value)
      if value
        @tracing_count += 1
      else
        @tracing_count -= 1
      end
    end

    def async_send_message_to_server(guid, method, params, metadata: nil)
      return if @closed_error

      callback = Concurrent::Promises.resolvable_future

      with_generated_id do |id|
        # register callback promise object first.
        # @see https://github.com/YusukeIwaki/puppeteer-ruby/pull/34
        @callbacks[id] = callback

        _metadata = {}
        frames = []
        if metadata
          frames = metadata[:stack]
          _metadata[:wallTime] = metadata[:wallTime]
          _metadata[:apiName] = metadata[:apiName]
          _metadata[:location] = metadata[:stack].first
          _metadata[:internal] = !metadata[:apiName]
          if metadata[:title]
            _metadata[:title] = metadata[:title]
          end
        end
        _metadata.compact!

        message = {
          id: id,
          guid: guid,
          method: method,
          params: replace_channels_with_guids(params),
          metadata: _metadata,
        }

        begin
          @transport.send_message(message)
        rescue => err
          @callbacks.delete(id)
          callback.reject(err)
          raise unless err.is_a?(Transport::AlreadyDisconnectedError)
        end

        if @tracing_count > 0 && !frames.empty? && guid != 'localUtils'
          @local_utils.add_stack_to_tracing_no_reply(id, frames)
        end
      end

      callback
    end

    def send_message_to_server(guid, method, params, metadata: nil)
      async_send_message_to_server(guid, method, params, metadata: metadata).value!
    end

    private

    # ```usage
    # connection.with_generated_id do |id|
    #   # play with id
    # end
    # ````
    def with_generated_id(&block)
      @last_id ||= 0
      block.call(@last_id += 1)
    end

    # @param guid [String]
    # @param parent [Playwright::ChannelOwner]
    # @note This method should be used internally. Accessed via .send method from Playwright::ChannelOwner, so keep private!
    def update_object_from_channel_owner(guid, parent)
      @objects[guid] = parent
    end

    # @param guid [String]
    # @note This method should be used internally. Accessed via .send method from Playwright::ChannelOwner, so keep private!
    def delete_object_from_channel_owner(guid)
      @objects.delete(guid)
    end

    def dispatch(msg)
      return if @closed_error

      id = msg['id']
      if id
        callback = @callbacks.delete(id)

        unless callback
          raise "Cannot find command to respond: #{id}"
        end

        error = msg['error']
        if error && !msg['result']
          parsed_error = ::Playwright::Error.parse(error['error'])
          parsed_error.log = msg['log']
          callback.reject(parsed_error)
        else
          result = replace_guids_with_channels(msg['result'])
          callback.fulfill(result)
        end

        return
      end

      guid = msg['guid']
      method = msg['method']
      params = msg['params']

      if method == "__create__"
        remote_object = create_remote_object(
          parent_guid: guid,
          type: params["type"],
          guid: params["guid"],
          initializer: params["initializer"],
        )
        if remote_object.is_a?(ChannelOwners::LocalUtils)
          @local_utils = remote_object
        end
        return
      end

      object = @objects[guid]
      unless object
        raise "Cannot find object to \"#{method}\": #{guid}"
      end

      if method == "__adopt__"
        child = @objects[params["guid"]]
        unless child
          raise "Unknown new child: #{params['guid']}"
        end
        object.send(:adopt!, child)
        return
      end

      if method == "__dispose__"
        object.send(:dispose!, reason: params["reason"])
        return
      end

      object.channel.emit(method, replace_guids_with_channels(params))
    end

    def replace_channels_with_guids(payload)
      if payload.nil?
        return nil
      end

      if payload.is_a?(Array)
        return payload.map{ |pl| replace_channels_with_guids(pl) }
      end

      if payload.is_a?(Channel)
        return { guid: payload.guid }
      end

      if payload.is_a?(Hash)
        return payload.map { |k, v| [k, replace_channels_with_guids(v)] }.to_h
      end

      payload
    end

    def replace_guids_with_channels(payload)
      if payload.nil?
        return nil
      end

      if payload.is_a?(Array)
        return payload.map{ |pl| replace_guids_with_channels(pl) }
      end

      if payload.is_a?(Hash)
        guid = payload['guid']
        if guid && @objects[guid]
          return @objects[guid].channel
        end

        return payload.map { |k, v| [k, replace_guids_with_channels(v)] }.to_h
      end

      payload
    end

    # @return [Playwright::ChannelOwner|nil]
    def create_remote_object(parent_guid:, type:, guid:, initializer:)
      parent = @objects[parent_guid]
      unless parent
        raise "Cannot find parent object #{parent_guid} to create #{guid}"
      end
      initializer = replace_guids_with_channels(initializer)

      result =
        begin
          ChannelOwners.const_get(type).new(
            parent,
            type,
            guid,
            initializer,
          )
        rescue NameError
          raise "Missing type #{type}"
        end

      callback = @waiting_for_object.delete(guid)
      callback&.fulfill(result)

      result
    end
  end
end
