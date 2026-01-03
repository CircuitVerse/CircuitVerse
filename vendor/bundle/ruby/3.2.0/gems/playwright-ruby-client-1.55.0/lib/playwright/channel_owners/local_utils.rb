module Playwright
  define_channel_owner :LocalUtils do
    def devices
      @devices ||= @initializer['deviceDescriptors'].map do |device|
        [device['name'], parse_device_descriptor(device['descriptor'])]
      end.to_h
    end

    # @param zip_file [String]
    def zip(params)
      @channel.send_message_to_server('zip', params)
      nil
    end


    # @param file [String]
    # @return [String] har ID
    def har_open(file)
      @channel.send_message_to_server('harOpen', file: file)
    end

    def har_lookup(har_id:, url:, method:, headers:, is_navigation_request:, post_data: nil)
      params = {
        harId: har_id,
        url: url,
        method: method,
        headers: headers,
        postData: post_data,
        isNavigationRequest: is_navigation_request,
      }.compact

      @channel.send_message_to_server_result('harLookup', params)
    end

    # @param har_id [String]
    def async_har_close(har_id)
      @channel.async_send_message_to_server('harClose', harId: har_id)
    end

    def har_unzip(zip_file, har_file)
      @channel.send_message_to_server('harUnzip', zipFile: zip_file, harFile: har_file)
    end

    def tracing_started(traces_dir, trace_name)
      params = {
        tracesDir: traces_dir,
        traceName: trace_name,
      }.compact
      @channel.send_message_to_server('tracingStarted', params)
    end

    def trace_discarded(stacks_id)
      @channel.send_message_to_server('traceDiscarded', stacksId: stacks_id)
    end

    def add_stack_to_tracing_no_reply(id, stack)
      @channel.async_send_message_to_server('addStackToTracingNoReply', callData: { id: id, stack: stack })
      nil
    end

    private def parse_device_descriptor(descriptor)
      # This return value can be passed into Browser#new_context as it is.
      # ex:
      # ```
      #   iPhone = playwright.devices['iPhone 6']
      #   context = browser.new_context(**iPhone)
      #   page = context.new_page
      #
      # ```
      {
        userAgent: descriptor['userAgent'],
        viewport: {
          width: descriptor['viewport']['width'],
          height: descriptor['viewport']['height'],
        },
        deviceScaleFactor: descriptor['deviceScaleFactor'],
        isMobile: descriptor['isMobile'],
        hasTouch: descriptor['hasTouch'],
      }
    end
  end
end
