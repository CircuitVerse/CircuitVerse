require 'fileutils'

module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_browser.py
  define_channel_owner :Browser do
    include Utils::Errors::TargetClosedErrorMethods
    include Utils::PrepareBrowserContextOptions

    private def after_initialize
      @connected = true
      @should_close_connection_on_close = false

      @contexts = Set.new
      @channel.on('context', ->(params) { did_create_context(ChannelOwners::BrowserContext.from(params['context'])) })
      @channel.on('close', method(:on_close))
      @close_reason = nil
    end

    private def close_reason
      @close_reason
    end

    def contexts
      @contexts.to_a
    end

    def browser_type
      @browser_type
    end

    def connected?
      @connected
    end

    def new_context(**options, &block)
      params = options.dup
      @browser_type.send(:update_with_playwright_selectors_options, params)
      prepare_browser_context_options(params)

      resp = @channel.send_message_to_server('newContext', params.compact)
      context = ChannelOwners::BrowserContext.from(resp)
      context.send(:initialize_har_from_options,
        record_har_content: params[:record_har_content],
        record_har_mode: params[:record_har_mode],
        record_har_omit_content: params[:record_har_omit_content],
        record_har_path: params[:record_har_path],
        record_har_url_filter: params[:record_har_url_filter],
      )
      @browser_type.send(:did_create_context, context, params)
      return context unless block

      begin
        block.call(context)
      ensure
        context.close
      end
    end

    def new_page(**options, &block)
      context = new_context(**options)
      page = context.new_page
      page.owned_context = context
      context.owner_page = page

      return page unless block

      begin
        block.call(page)
      ensure
        page.close
      end
    end

    def close(reason: nil)
      @close_reason = reason
      if @should_close_connection_on_close
        @connection.stop
      else
        @channel.send_message_to_server('close', { reason: reason }.compact)
      end
      nil
    rescue => err
      raise unless target_closed_error?(err)
    end

    def version
      @initializer['version']
    end

    def new_browser_cdp_session
      resp = @channel.send_message_to_server('newBrowserCDPSession')
      ChannelOwners::CDPSession.from(resp)
    end

    def start_tracing(page: nil, categories: nil, path: nil, screenshots: nil)
      params = {
        page: page&.channel,
        categories: categories,
        screenshots: screenshots,
      }.compact
      @cr_tracing_path = path

      @channel.send_message_to_server('startTracing', params)
    end

    def stop_tracing
      artifact = ChannelOwners::Artifact.from(@channel.send_message_to_server("stopTracing"))
      data = artifact.read_into_buffer
      if @cr_tracing_path
        File.dirname(@cr_tracing_path).tap do |dir|
          FileUtils.mkdir_p(dir) unless File.exist?(dir)
        end
        File.open(@cr_tracing_path, 'wb') { |f| f.write(data) }
      end
      data
    end

    # called from BrowserType
    private def connect_to_browser_type(browser_type, traces_dir)
      # Note: when using connect(), `browserType` is different from `this.parent`.
      # This is why browser type is not wired up in the constructor, and instead this separate method is called later on.
      @browser_type = browser_type
      @traces_dir = traces_dir
      @contexts.each do |context|
        setup_browser_context(context)
      end
    end

    private def did_create_context(context)
      context.browser = self
      @contexts << context

      # Note: when connecting to a browser, initial contexts arrive before `_browserType` is set,
      # and will be configured later in `ConnectToBrowserType`.
      if @browser_type
        setup_browser_context(context)
      end
    end

    private def setup_browser_context(context)
      context.tracing.send(:update_traces_dir, @traces_dir)
      @browser_type.send(:playwright_selectors_browser_contexts) << context
    end

    private def on_close(_ = {})
      @connected = false
      emit(Events::Browser::Disconnected, self)
      @closed_or_closing = true
    end

    # called from BrowserContext#initialize
    private def add_context(context)
      @contexts << context
    end

    private def should_close_connection_on_close!
      @should_close_connection_on_close = true
    end

    # called from BrowserContext#on_close with send(:remove_context), so keep private.
    private def remove_context(context)
      @contexts.delete(context)
    end
  end
end
