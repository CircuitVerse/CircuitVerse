module Playwright
  define_channel_owner :AndroidDevice do
    include Utils::PrepareBrowserContextOptions

    private def after_initialize
      @input = AndroidInputImpl.new(@channel)
      @should_close_connection_on_close = false
      @timeout_settings = @parent.send(:_timeout_settings)
    end

    def should_close_connection_on_close!
      @should_close_connection_on_close = true
    end

    attr_reader :input

    def serial
      @initializer['serial']
    end

    def model
      @initializer['model']
    end

    private def to_regex(value)
      case value
      when nil
        nil
      when Regexp
        value
      else
        Regexp.new("^#{value}$")
      end
    end

    private def to_selector_channel(selector)
      {
        checkable: selector[:checkable],
        checked: selector[:checked],
        clazz: to_regex(selector[:clazz]),
        pkg: to_regex(selector[:pkg]),
        desc: to_regex(selector[:desc]),
        res: to_regex(selector[:res]),
        text: to_regex(selector[:text]),
        clickable: selector[:clickable],
        depth: selector[:depth],
        enabled: selector[:enabled],
        focusable: selector[:focusable],
        focused: selector[:focused],
        hasChild: selector[:hasChild] ? { androidSelector: to_selector_channel(selector[:hasChild][:selector]) } : nil,
        hasDescendant: selector[:hasDescendant] ? {
          androidSelector: to_selector_channel(selector[:hasDescendant][:selector]),
          maxDepth: selector[:hasDescendant][:maxDepth],
        } : nil,
        longClickable: selector[:longClickable],
        scrollable: selector[:scrollable],
        selected: selector[:selected],
      }.compact
    end

    def tap_on(selector, duration: nil, timeout: nil)
      params = {
        androidSelector: to_selector_channel(selector),
        duration: duration,
        timeout: @timeout_settings.timeout(timeout),
      }.compact
      @channel.send_message_to_server('tap', params)
    end

    def info(selector)
      @channel.send_message_to_server('info', androidSelector: to_selector_channel(selector))
    end

    def screenshot(path: nil)
      encoded_binary = @channel.send_message_to_server('screenshot')
      decoded_binary = Base64.strict_decode64(encoded_binary)
      if path
        File.open(path, 'wb') do |f|
          f.write(decoded_binary)
        end
      end
      decoded_binary
    end

    def close
      emit(Events::AndroidDevice::Close)
      if @should_close_connection_on_close
        @connection.stop
      else
        @channel.send_message_to_server('close')
      end
    end

    def shell(command)
      resp = @channel.send_message_to_server('shell', command: command)
      Base64.strict_decode64(resp)
    end

    def launch_browser(pkg: nil, **options, &block)
      params = options.dup
      params[:pkg] = pkg
      params.compact!
      prepare_browser_context_options(params)

      resp = @channel.send_message_to_server('launchBrowser', params)
      context = ChannelOwners::BrowserContext.from(resp)

      if block
        begin
          block.call(context)
        ensure
          context.close
        end
      else
        context
      end
    end
  end
end
