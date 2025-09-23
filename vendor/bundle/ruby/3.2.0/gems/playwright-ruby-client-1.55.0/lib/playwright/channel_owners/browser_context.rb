module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_browser_context.py
  define_channel_owner :BrowserContext do
    include Utils::PrepareBrowserContextOptions

    attr_accessor :browser
    attr_writer :owner_page, :options
    attr_reader :clock, :tracing, :request

    private def after_initialize
      @options = @initializer['options']
      @pages = Set.new
      @routes = []
      @bindings = {}
      @timeout_settings = TimeoutSettings.new
      @service_workers = Set.new
      @background_pages = Set.new
      @owner_page = nil

      @tracing = ChannelOwners::Tracing.from(@initializer['tracing'])
      @request = ChannelOwners::APIRequestContext.from(@initializer['requestContext'])
      @request.send(:_update_timeout_settings, @timeout_settings)
      @clock = ClockImpl.new(self)
      @har_recorders = {}

      @channel.on('bindingCall', ->(params) { on_binding(ChannelOwners::BindingCall.from(params['binding'])) })
      @channel.once('close', ->(_) { on_close })
      @channel.on('page', ->(params) { on_page(ChannelOwners::Page.from(params['page']) )})
      @channel.on('route', ->(params) { on_route(ChannelOwners::Route.from(params['route'])) })
      @channel.on('backgroundPage', ->(params) {
        on_background_page(ChannelOwners::Page.from(params['page']))
      })
      @channel.on('serviceWorker', ->(params) {
        on_service_worker(ChannelOwners::Worker.from(params['worker']))
      })
      @channel.on('console', ->(params) {
        on_console_message(ConsoleMessageImpl.new(params))
      })
      @channel.on('pageError', ->(params) {
        on_page_error(
          Error.parse(params['error']['error']),
          ChannelOwners::Page.from_nullable(params['page']),
        )
      })
      @channel.on('dialog', ->(params) {
        on_dialog(ChannelOwners::Dialog.from(params['dialog']))
      })
      @channel.on('request', ->(params) {
        on_request(
          ChannelOwners::Request.from(params['request']),
          ChannelOwners::Page.from_nullable(params['page']),
        )
      })
      @channel.on('requestFailed', ->(params) {
        on_request_failed(
          ChannelOwners::Request.from(params['request']),
          params['responseEndTiming'],
          params['failureText'],
          ChannelOwners::Page.from_nullable(params['page']),
        )
      })
      @channel.on('requestFinished', method(:on_request_finished))
      @channel.on('response', ->(params) {
        on_response(
          ChannelOwners::Response.from(params['response']),
          ChannelOwners::Page.from_nullable(params['page']),
        )
      })

      @closed_promise = Concurrent::Promises.resolvable_future
      @close_reason = nil
      set_event_to_subscription_mapping({
        Events::BrowserContext::Console => 'console',
        Events::BrowserContext::Dialog => 'dialog',
        Events::BrowserContext::Request => "request",
        Events::BrowserContext::Response => "response",
        Events::BrowserContext::RequestFinished => "requestFinished",
        Events::BrowserContext::RequestFailed => "requestFailed",
      })

      @close_was_called = false
    end

    private def initialize_har_from_options(record_har_path:, record_har_content:, record_har_omit_content:, record_har_url_filter:, record_har_mode:)
      return unless record_har_path

      default_policy = record_har_path.end_with?('.zip') ? 'attach' : 'embed'
      content_policy = record_har_content || (record_har_omit_content ? 'omit' : default_policy)
      record_into_har(record_har_path, nil,
        url: record_har_url_filter,
        update_content: content_policy,
        update_mode: record_har_mode || 'full',
      )
    end

    private def update_options(context_options:, browser_options:)
      @options = context_options
      @tracing.send(:update_traces_dir, browser_options[:tracesDir])
    end

    private def on_page(page)
      @pages << page
      emit(Events::BrowserContext::Page, page)
      page.send(:emit_popup_event_from_browser_context)
    end

    private def on_background_page(page)
      @background_pages << page
      emit(Events::BrowserContext::BackgroundPage, page)
    end

    private def on_route(route)
      route.send(:update_context, self)

      # It is not desired to use PlaywrightApi.wrap directly.
      # However it is a little difficult to define wrapper for `handler` parameter in generate_api.
      # Just a workaround...
      Concurrent::Promises.future(PlaywrightApi.wrap(route)) do |wrapped_route|
        handled = @routes.any? do |handler_entry|
          next false unless handler_entry.match?(route.request.url)

          promise = Concurrent::Promises.resolvable_future
          route.send(:set_handling_future, promise)

          promise_handled = Concurrent::Promises.zip(
            promise,
            handler_entry.async_handle(wrapped_route)
          ).value!.first

          promise_handled
        end

        @routes.reject!(&:expired?)
        if @routes.count == 0
          async_update_interception_patterns
        end

        unless handled
          route.send(:async_continue_route, internal: true).rescue do |err|
            puts err, err.backtrace
          end
        end
      end.rescue do |err|
        puts err, err.backtrace
      end
    end

    private def on_binding(binding_call)
      func = @bindings[binding_call.name]
      if func
        binding_call.call_async(func)
      end
    end

    private def on_request_failed(request, response_end_timing, failure_text, page)
      request.send(:update_failure_text, failure_text)
      request.send(:update_response_end_timing, response_end_timing)
      emit(Events::BrowserContext::RequestFailed, request)
      page&.emit(Events::Page::RequestFailed, request)
    end

    private def on_request_finished(params)
      request = ChannelOwners::Request.from(params['request'])
      response = ChannelOwners::Response.from_nullable(params['response'])
      page = ChannelOwners::Page.from_nullable(params['page'])

      request.send(:update_response_end_timing, params['responseEndTiming'])
      emit(Events::BrowserContext::RequestFinished, request)
      page&.emit(Events::Page::RequestFinished, request)
      response&.send(:mark_as_finished)
    end

    private def on_console_message(message)
      emit(Events::BrowserContext::Console, message)
      if (page = message.page)
        page.emit(Events::Page::Console, message)
      end
    end

    private def on_dialog(dialog)
      consumed_by_context = emit(Events::BrowserContext::Dialog, dialog)
      if (page = dialog.page)
        consumed_by_page = page.emit(Events::Page::Dialog, dialog)
      end

      if !consumed_by_context && !consumed_by_page
        if dialog.type == 'beforeunload'
          dialog.accept_async
        else
          dialog.dismiss
        end
      end
    end

    private def on_page_error(error, page)
      emit(Events::BrowserContext::WebError, WebError.new(error, page))
      if page
        page.emit(Events::Page::PageError, error)
      end
    end

    private def on_request(request, page)
      emit(Events::BrowserContext::Request, request)
      page&.emit(Events::Page::Request, request)
    end

    private def on_response(response, page)
      emit(Events::BrowserContext::Response, response)
      page&.emit(Events::Page::Response, response)
    end

    private def on_service_worker(worker)
      worker.context = self
      @service_workers << worker
      emit(Events::BrowserContext::ServiceWorker, worker)
    end

    def background_pages
      @background_pages.to_a
    end

    def service_workers
      @service_workers.to_a
    end

    def new_cdp_session(page)
      resp = @channel.send_message_to_server('newCDPSession', page: page.channel)
      ChannelOwners::CDPSession.from(resp)
    end

    def set_default_navigation_timeout(timeout)
      @timeout_settings.default_navigation_timeout = timeout
    end

    def set_default_timeout(timeout)
      @timeout_settings.default_timeout = timeout
    end

    def pages
      @pages.to_a
    end

    # @returns [Playwright::Page]
    def new_page(&block)
      raise 'Please use browser.new_context' if @owner_page
      resp = @channel.send_message_to_server('newPage')
      page = ChannelOwners::Page.from(resp)
      return page unless block

      begin
        block.call(page)
      ensure
        page.close
      end
    end

    def cookies(urls: nil)
      target_urls =
        if urls.nil?
          []
        elsif urls.is_a?(Enumerable)
          urls
        else
          [urls]
        end
      @channel.send_message_to_server('cookies', urls: target_urls)
    end

    def add_cookies(cookies)
      @channel.send_message_to_server('addCookies', cookies: cookies)
    end

    def clear_cookies(domain: nil, name: nil, path: nil)
      params = {}

      case name
      when String
        params[:name] = name
      when Regexp
        regex = JavaScript::Regex.new(name)
        params[:nameRegexSource] = regex.source
        params[:nameRegexFlags] = regex.flag
      end

      case domain
      when String
        params[:domain] = domain
      when Regexp
        regex = JavaScript::Regex.new(domain)
        params[:domainRegexSource] = regex.source
        params[:domainRegexFlags] = regex.flag
      end

      case path
      when String
        params[:path] = path
      when Regexp
        regex = JavaScript::Regex.new(path)
        params[:pathRegexSource] = regex.source
        params[:pathRegexFlags] = regex.flag
      end

      @channel.send_message_to_server('clearCookies', params)
    end

    def grant_permissions(permissions, origin: nil)
      params = {
        permissions: permissions,
        origin: origin,
      }.compact
      @channel.send_message_to_server('grantPermissions', params)
    end

    def clear_permissions
      @channel.send_message_to_server('clearPermissions')
    end

    def set_geolocation(geolocation)
      @channel.send_message_to_server('setGeolocation', geolocation: geolocation)
    end

    def set_extra_http_headers(headers)
      @channel.send_message_to_server('setExtraHTTPHeaders',
        headers: HttpHeaders.new(headers).as_serialized)
    end

    def set_offline(offline)
      @channel.send_message_to_server('setOffline', offline: offline)
    end

    def add_init_script(path: nil, script: nil)
      source =
        if path
          JavaScript::SourceUrl.new(File.read(path), path).to_s
        elsif script
          script
        else
          raise ArgumentError.new('Either path or script parameter must be specified')
        end

      @channel.send_message_to_server('addInitScript', source: source)
      nil
    end

    def expose_binding(name, callback, handle: nil)
      if @pages.any? { |page| page.send(:has_bindings?, name) }
        raise ArgumentError.new("Function \"#{name}\" has been already registered in one of the pages")
      end
      if @bindings.key?(name)
        raise ArgumentError.new("Function \"#{name}\" has been already registered")
      end
      params = {
        name: name,
        needsHandle: handle,
      }.compact
      @bindings[name] = callback
      @channel.send_message_to_server('exposeBinding', params)
    end

    def expose_function(name, callback)
      expose_binding(name, ->(_source, *args) { callback.call(*args) }, )
    end

    def route(url, handler, times: nil)
      entry = RouteHandler.new(url, base_url, handler, times)
      @routes.unshift(entry)
      update_interception_patterns
    end

    def unroute_all(behavior: nil)
      @routes.clear
      update_interception_patterns
    end

    def unroute(url, handler: nil)
      @routes.reject! do |handler_entry|
        handler_entry.same_value?(url: url, handler: handler)
      end
      update_interception_patterns
    end

    private def record_into_har(har, page, url:, update_content:, update_mode:)
      options = {
        zip: har.end_with?('.zip'),
        content: update_content || 'attach',
      }

      if url.is_a?(Regexp)
        regex = ::Playwright::JavaScript::Regex.new(url)
        options[:urlRegexSource] = regex.source
        options[:urlRegexFlags] = regex.flag
      elsif url.is_a?(String)
        options[:urlGlob] = url
      end

      params = { options: options }
      if page
        params[:page] = page.channel
      end

      har_id = @channel.send_message_to_server('harStart', params)
      @har_recorders[har_id] = { path: har, content: update_content || 'attach' }
    end

    def route_from_har(har, notFound: nil, update: nil, updateContent: nil, updateMode: nil, url: nil)
      if update
        record_into_har(har, nil, url: url, update_content: updateContent, update_mode: updateMode)
        return
      end

      router = HarRouter.create(
        @connection.local_utils,
        har.to_s,
        notFound || "abort",
        url_match: url,
      )
      router.add_context_route(self)
    end

    private def async_update_interception_patterns
      patterns = RouteHandler.prepare_interception_patterns(@routes)
      @channel.async_send_message_to_server('setNetworkInterceptionPatterns', patterns: patterns)
    end

    private def update_interception_patterns
      patterns = RouteHandler.prepare_interception_patterns(@routes)
      @channel.send_message_to_server('setNetworkInterceptionPatterns', patterns: patterns)
    end

    def expect_event(event, predicate: nil, timeout: nil, &block)
      waiter = Waiter.new(self, wait_name: "browser_context.expect_event(#{event})")
      timeout_value = timeout || @timeout_settings.timeout
      waiter.reject_on_timeout(timeout_value, "Timeout #{timeout}ms exceeded while waiting for event \"#{event}\"")
      unless event == Events::BrowserContext::Close
        waiter.reject_on_event(self, Events::BrowserContext::Close, TargetClosedError.new)
      end
      waiter.wait_for_event(self, event, predicate: predicate)

      block&.call

      waiter.result.value!
    end

    private def on_close
      if @browser
        @browser.send(:remove_context, self)
        @browser.browser_type.send(:playwright_selectors_browser_contexts).delete(self)
      end
      emit(Events::BrowserContext::Close)
      @closed_promise.fulfill(true)
    end

    def close(reason: nil)
      return if @close_was_called
      @close_was_called = true
      @close_reason = reason
      @request.dispose(reason: reason)
      inner_close
      @channel.send_message_to_server('close', { reason: reason }.compact)
      @closed_promise.value!
      nil
    end

    private def inner_close
      @har_recorders.each do |har_id, params|
        har = ChannelOwners::Artifact.from(@channel.send_message_to_server('harExport', harId: har_id))
        # Server side will compress artifact if content is attach or if file is .zip.
        compressed = params[:content] == "attach" || params[:path].end_with?('.zip')
        need_comppressed = params[:path].end_with?('.zip')
        if compressed && !need_comppressed
          tmp_path = "#{params[:path]}.tmp"
          har.save_as(tmp_path)
          @connection.local_utils.har_unzip(tmp_path, params[:path])
        else
          har.save_as(params[:path])
        end

        har.delete
      end
    end

    # REMARK: enable_debug_console is playwright-ruby-client specific method.
    def enable_debug_console!
      # Ruby is not supported in Playwright officially,
      # and causes error:
      #
      #  Error:
      #  ===============================
      #  Unsupported language: 'ruby'
      #  ===============================
      #
      # So, launch inspector as Python app.
      # NOTE: This should be used only for Page#pause at this moment.
      @channel.send_message_to_server('enableRecorder', language: :python)
      @debug_console_enabled = true
    end

    class DebugConsoleNotEnabledError < StandardError
      def initialize
        super('Debug console should be enabled in advance, by calling `browser_context.enable_debug_console!`')
      end
    end

    def pause
      unless @debug_console_enabled
        raise DebugConsoleNotEnabledError.new
      end
      @channel.send_message_to_server('pause')
    end

    def storage_state(path: nil, indexedDB: nil)
      @channel.send_message_to_server_result('storageState', { indexedDB: indexedDB }.compact).tap do |result|
        if path
          File.open(path, 'w') do |f|
            f.write(JSON.dump(result))
          end
        end
      end
    end

    private def effective_close_reason
      @close_reason || @browser&.send(:close_reason)
    end

    def expect_console_message(predicate: nil, timeout: nil, &block)
      params = {
        predicate: predicate,
        timeout: timeout,
      }.compact
      expect_event(Events::BrowserContext::Console, params, &block)
    end

    def expect_page(predicate: nil, timeout: nil, &block)
      params = {
        predicate: predicate,
        timeout: timeout,
      }.compact
      expect_event(Events::BrowserContext::Page, params, &block)
    end

    # called from Page#on_close with send(:remove_page, page), so keep private
    private def remove_page(page)
      @pages.delete(page)
    end

    private def remove_background_page(page)
      @background_pages.delete(page)
    end

    private def remove_service_worker(worker)
      @service_workers.delete(worker)
    end

    # called from Page with send(:_timeout_settings), so keep private.
    private def _timeout_settings
      @timeout_settings
    end

    private def has_record_video_option?
      @options.key?(:recordVideo)
    end

    private def base_url
      @options[:baseURL]
    end

    # called from InputFiles
    # @param filepath [string]
    # @return [WritableStream, Array<WritableStream>]
    private def create_temp_files(local_directory, files)
      if local_directory
        params = {
          rootDirName: File.basename(local_directory),
          items: files.map do |filepath|
            {
              name: Pathname.new(filepath).relative_path_from(Pathname.new(local_directory)).to_s,
              lastModifiedMs: File.mtime(filepath).to_i * 1000,
            }
          end
        }
      else
        params = {
          items: files.map do |filepath|
            {
              name: File.basename(filepath),
              lastModifiedMs: File.mtime(filepath).to_i * 1000,
            }
          end
        }
      end

      result = @channel.send_message_to_server_result('createTempFiles', params)

      [
        ChannelOwners::WritableStream.from_nullable(result['rootDir']),
        result['writableStreams'].map do |s|
          ChannelOwners::WritableStream.from(s)
        end,
      ]
    end

    private def clock_fast_forward(ticks_params)
      @channel.send_message_to_server('clockFastForward', ticks_params)
    end

    private def clock_install(time_params)
      @channel.send_message_to_server('clockInstall', time_params)
    end

    private def clock_pause_at(time_params)
      @channel.send_message_to_server('clockPauseAt', time_params)
    end

    private def clock_resume
      @channel.send_message_to_server('clockResume')
    end

    private def clock_run_for(ticks_params)
      @channel.send_message_to_server('clockRunFor', ticks_params)
    end

    private def clock_set_fixed_time(time_params)
      @channel.send_message_to_server('clockSetFixedTime', time_params)
    end

    private def clock_set_system_time(time_params)
      @channel.send_message_to_server('clockSetSystemTime', time_params)
    end

    private def register_selector_engine(selector_engine)
      @channel.send_message_to_server('registerSelectorEngine', { selectorEngine: selector_engine })
    end

    private def set_test_id_attribute_name(test_id_attribute_name)
      @channel.send_message_to_server('setTestIdAttributeName', { testIdAttributeName: test_id_attribute_name })
      ::Playwright::LocatorUtils.instance_variable_set(:@test_id_attribute_name, test_id_attribute_name)
    end
  end
end
