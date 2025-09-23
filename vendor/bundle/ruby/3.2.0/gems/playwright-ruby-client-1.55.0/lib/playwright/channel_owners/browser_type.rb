module Playwright
  define_channel_owner :BrowserType do
    include Utils::PrepareBrowserContextOptions

    private def after_initialize
      @timeout_settings = TimeoutSettings.new
    end

    private def update_playwright(playwright)
      @playwright = playwright
    end

    def name
      @initializer['name']
    end

    def executable_path
      @initializer['executablePath']
    end

    def launch(options, &block)
      params = options.dup
      params[:timeout] ||= @timeout_settings.launch_timeout
      resp = @channel.send_message_to_server('launch', params.compact)
      browser = ChannelOwners::Browser.from(resp)
      browser.send(:connect_to_browser_type, self, params[:tracesDir])
      return browser unless block

      begin
        block.call(browser)
      ensure
        browser.close
      end
    end

    def launch_persistent_context(userDataDir, **options, &block)
      params = options.dup
      prepare_browser_context_options(params)
      params['userDataDir'] = userDataDir
      params[:timeout] ||= @timeout_settings.launch_timeout

      result = @channel.send_message_to_server_result('launchPersistentContext', params.compact)
      browser = ChannelOwners::Browser.from(result['browser'])
      browser.send(:connect_to_browser_type, self, params[:tracesDir])
      context = ChannelOwners::BrowserContext.from(result['context'])
      context.send(:initialize_har_from_options,
        record_har_content: params[:record_har_content],
        record_har_mode: params[:record_har_mode],
        record_har_omit_content: params[:record_har_omit_content],
        record_har_path: params[:record_har_path],
        record_har_url_filter: params[:record_har_url_filter],
      )

      return context unless block

      begin
        block.call(context)
      ensure
        context.close
      end
    end

    def connect_over_cdp(endpointURL, headers: nil, slowMo: nil, timeout: nil, &block)
      raise 'Connecting over CDP is only supported in Chromium.' unless name == 'chromium'

      params = {
        endpointURL: endpointURL,
        headers: headers,
        slowMo: slowMo,
        timeout: @timeout_settings.timeout(timeout),
      }.compact

      if headers
        params[:headers] = HttpHeaders.new(headers).as_serialized
      end

      result = @channel.send_message_to_server_result('connectOverCDP', params)
      browser = ChannelOwners::Browser.from(result['browser'])
      browser.send(:connect_to_browser_type, self, nil)

      if block
        begin
          block.call(browser)
        ensure
          browser.close
        end
      else
        browser
      end
    end

    private def did_create_context(context, context_options = {}, browser_options = {})
      context.send(:update_options, context_options: context_options, browser_options: browser_options)
    end

    private def update_with_playwright_selectors_options(options)
      selectors = @playwright&.selectors
      if selectors
        selectors.send(:update_with_selector_options, options)
      else
        options
      end
    end

    private def playwright_selectors_browser_contexts
      selectors = @playwright&.selectors
      if selectors
        selectors.send(:contexts_for_selectors)
      else
        []
      end
    end
  end
end
