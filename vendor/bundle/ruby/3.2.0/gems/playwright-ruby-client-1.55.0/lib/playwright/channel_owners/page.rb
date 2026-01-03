require 'base64'
require_relative '../locator_utils'

module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_page.py
  define_channel_owner :Page do
    include Utils::Errors::TargetClosedErrorMethods
    include LocatorUtils
    attr_writer :owned_context

    private def after_initialize
      @browser_context = @parent
      @timeout_settings = TimeoutSettings.new(@browser_context.send(:_timeout_settings))
      @accessibility = AccessibilityImpl.new(@channel)
      @keyboard = KeyboardImpl.new(@channel)
      @mouse = MouseImpl.new(@channel)
      @touchscreen = TouchscreenImpl.new(@channel)

      if @initializer['viewportSize']
        @viewport_size = {
          width: @initializer['viewportSize']['width'],
          height: @initializer['viewportSize']['height'],
        }
      end
      @closed = false
      @workers = Set.new
      @bindings = {}
      @routes = []

      @main_frame = ChannelOwners::Frame.from(@initializer['mainFrame'])
      @main_frame.send(:update_page_from_page, self)
      @frames = Set.new
      @frames << @main_frame
      @opener = ChannelOwners::Page.from_nullable(@initializer['opener'])
      @close_reason = nil

      @channel.on('bindingCall', ->(params) { on_binding(ChannelOwners::BindingCall.from(params['binding'])) })
      @closed_or_crashed_promise = Concurrent::Promises.resolvable_future
      @channel.once('close', ->(_) { on_close })
      @channel.on('crash', ->(_) { on_crash })
      @channel.on('download', method(:on_download))
      @channel.on('fileChooser', ->(params) {
        chooser = FileChooserImpl.new(
                    page: self,
                    timeout_settings: @timeout_settings,
                    element_handle: ChannelOwners::ElementHandle.from(params['element']),
                    is_multiple: params['isMultiple'])
        emit(Events::Page::FileChooser, chooser)
      })
      @channel.on('frameAttached', ->(params) {
        on_frame_attached(ChannelOwners::Frame.from(params['frame']))
      })
      @channel.on('frameDetached', ->(params) {
        on_frame_detached(ChannelOwners::Frame.from(params['frame']))
      })
      @channel.on('pageError', ->(params) {
        emit(Events::Page::PageError, Error.parse(params['error']['error']))
      })
      @channel.on('route', ->(params) { on_route(ChannelOwners::Route.from(params['route'])) })
      @channel.on('video', method(:on_video))
      @channel.on('viewportSizeChanged', method(:on_viewport_size_changed))
      @channel.on('webSocket', ->(params) {
        emit(Events::Page::WebSocket, ChannelOwners::WebSocket.from(params['webSocket']))
      })
      @channel.on('worker', ->(params) {
        worker = ChannelOwners::Worker.from(params['worker'])
        on_worker(worker)
      })

      set_event_to_subscription_mapping({
        Events::Page::Console => "console",
        Events::Page::Dialog => "dialog",
        Events::Page::Request => "request",
        Events::Page::Response => "response",
        Events::Page::RequestFinished => "requestFinished",
        Events::Page::RequestFailed => "requestFailed",
        Events::Page::FileChooser => "fileChooser",
      })
    end

    attr_reader \
      :accessibility,
      :keyboard,
      :mouse,
      :touchscreen,
      :viewport_size,
      :main_frame

    private def on_frame_attached(frame)
      frame.send(:update_page_from_page, self)
      @frames << frame
      emit(Events::Page::FrameAttached, frame)
    end

    private def on_frame_detached(frame)
      @frames.delete(frame)
      frame.detached = true
      emit(Events::Page::FrameDetached, frame)
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
          @browser_context.send(:on_route, route)
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
      @browser_context.send(:on_binding, binding_call)
    end

    private def on_worker(worker)
      worker.page = self
      @workers << worker
      emit(Events::Page::Worker, worker)
    end

    private def on_close
      @closed = true
      @browser_context.send(:remove_page, self)
      @browser_context.send(:remove_background_page, self)
      if @closed_or_crashed_promise.pending?
        @closed_or_crashed_promise.fulfill(close_error_with_reason)
      end
      emit(Events::Page::Close)
    end

    private def on_crash
      if @closed_or_crashed_promise.pending?
        @closed_or_crashed_promise.fulfill(TargetClosedError.new)
      end
      emit(Events::Page::Crash)
    end

    private def on_download(params)
      artifact = ChannelOwners::Artifact.from(params['artifact'])
      download = DownloadImpl.new(
        page: self,
        url: params['url'],
        suggested_filename: params['suggestedFilename'],
        artifact: artifact,
      )
      emit(Events::Page::Download, download)
    end

    private def on_video(params)
      artifact = ChannelOwners::Artifact.from(params['artifact'])
      video.send(:set_artifact, artifact)
    end

    private def on_viewport_size_changed(params)
      @viewport_size = {
        width: params['viewportSize']['width'],
        height: params['viewportSize']['height'],
      }
    end

    # @override
    private def perform_event_emitter_callback(event, callback, args)
      should_callback_async = [
        Events::Page::Dialog,
        Events::Page::Response,
      ].freeze

      if should_callback_async.include?(event)
        Concurrent::Promises.future { super }
      else
        super
      end
    end

    def context
      @browser_context
    end

    def clock
      @browser_context.clock
    end

    def opener
      if @opener&.closed?
        nil
      else
        @opener
      end
    end

    private def emit_popup_event_from_browser_context
      if @opener && !@opener.closed?
        @opener.emit(Events::Page::Popup, self)
      end
    end

    def frame(name: nil, url: nil)
      if name
        @frames.find { |f| f.name == name }
      elsif url
        matcher = UrlMatcher.new(url, base_url: @browser_context.send(:base_url))
        @frames.find { |f| matcher.match?(f.url) }
      else
        raise ArgumentError.new('Either name or url matcher should be specified')
      end
    end

    def frames
      @frames.to_a
    end

    def set_default_navigation_timeout(timeout)
      @timeout_settings.default_navigation_timeout = timeout
    end

    def set_default_timeout(timeout)
      @timeout_settings.default_timeout = timeout
    end

    def query_selector(selector, strict: nil)
      @main_frame.query_selector(selector, strict: strict)
    end

    def query_selector_all(selector)
      @main_frame.query_selector_all(selector)
    end

    def wait_for_selector(selector, state: nil, strict: nil, timeout: nil)
      @main_frame.wait_for_selector(selector, state: state, strict: strict, timeout: timeout)
    end

    def checked?(selector, strict: nil, timeout: nil)
      @main_frame.checked?(selector, strict: strict, timeout: timeout)
    end

    def disabled?(selector, strict: nil, timeout: nil)
      @main_frame.disabled?(selector, strict: strict, timeout: timeout)
    end

    def editable?(selector, strict: nil, timeout: nil)
      @main_frame.editable?(selector, strict: strict, timeout: timeout)
    end

    def enabled?(selector, strict: nil, timeout: nil)
      @main_frame.enabled?(selector, strict: strict, timeout: timeout)
    end

    def hidden?(selector, strict: nil, timeout: nil)
      @main_frame.hidden?(selector, strict: strict, timeout: timeout)
    end

    def visible?(selector, strict: nil, timeout: nil)
      @main_frame.visible?(selector, strict: strict, timeout: timeout)
    end

    def dispatch_event(selector, type, eventInit: nil, strict: nil, timeout: nil)
      @main_frame.dispatch_event(selector, type, eventInit: eventInit, strict: strict, timeout: timeout)
    end

    def evaluate(pageFunction, arg: nil)
      @main_frame.evaluate(pageFunction, arg: arg)
    end

    def evaluate_handle(pageFunction, arg: nil)
      @main_frame.evaluate_handle(pageFunction, arg: arg)
    end

    def eval_on_selector(selector, pageFunction, arg: nil, strict: nil)
      @main_frame.eval_on_selector(selector, pageFunction, arg: arg, strict: strict)
    end

    def eval_on_selector_all(selector, pageFunction, arg: nil)
      @main_frame.eval_on_selector_all(selector, pageFunction, arg: arg)
    end

    def add_script_tag(content: nil, path: nil, type: nil, url: nil)
      @main_frame.add_script_tag(content: content, path: path, type: type, url: url)
    end

    def add_style_tag(content: nil, path: nil, url: nil)
      @main_frame.add_style_tag(content: content, path: path, url: url)
    end

    def expose_function(name, callback)
      @channel.send_message_to_server('exposeBinding', name: name)
      @bindings[name] = ->(_source, *args) { callback.call(*args) }
    end

    def expose_binding(name, callback, handle: nil)
      params = {
        name: name,
        needsHandle: handle,
      }.compact
      @channel.send_message_to_server('exposeBinding', params)
      @bindings[name] = callback
    end

    def set_extra_http_headers(headers)
      serialized_headers = HttpHeaders.new(headers).as_serialized
      @channel.send_message_to_server('setExtraHTTPHeaders', headers: serialized_headers)
    end

    def url
      @main_frame.url
    end

    def content
      @main_frame.content
    end

    def set_content(html, timeout: nil, waitUntil: nil)
      @main_frame.set_content(html, timeout: timeout, waitUntil: waitUntil)
    end

    def goto(url, timeout: nil, waitUntil: nil, referer: nil)
      @main_frame.goto(url, timeout: timeout,  waitUntil: waitUntil, referer: referer)
    end

    def reload(timeout: nil, waitUntil: nil)
      params = {
        timeout: @timeout_settings.timeout(timeout),
        waitUntil: waitUntil,
      }.compact
      resp = @channel.send_message_to_server('reload', params)
      ChannelOwners::Response.from_nullable(resp)
    end

    def wait_for_load_state(state: nil, timeout: nil)
      @main_frame.wait_for_load_state(state: state, timeout: timeout)
    end

    def wait_for_url(url, timeout: nil, waitUntil: nil)
      @main_frame.wait_for_url(url, timeout: timeout,  waitUntil: waitUntil)
    end

    def go_back(timeout: nil, waitUntil: nil)
      params = { timeout: @timeout_settings.timeout(timeout), waitUntil: waitUntil }.compact
      resp = @channel.send_message_to_server('goBack', params)
      ChannelOwners::Response.from_nullable(resp)
    end

    def go_forward(timeout: nil, waitUntil: nil)
      params = { timeout: @timeout_settings.timeout(timeout), waitUntil: waitUntil }.compact
      resp = @channel.send_message_to_server('goForward', params)
      ChannelOwners::Response.from_nullable(resp)
    end

    def emulate_media(colorScheme: nil, contrast: nil, forcedColors: nil, media: nil, reducedMotion: nil)
      params = {
        colorScheme: no_override_if_null(colorScheme),
        contrast: no_override_if_null(contrast),
        forcedColors: no_override_if_null(forcedColors),
        media: no_override_if_null(media),
        reducedMotion: no_override_if_null(reducedMotion),
      }.compact
      @channel.send_message_to_server('emulateMedia', params)

      nil
    end

    private def no_override_if_null(target)
      if target == 'null'
        'no-override'
      else
        target
      end
    end

    def set_viewport_size(viewportSize)
      @viewport_size = viewportSize
      @channel.send_message_to_server('setViewportSize', { viewportSize: viewportSize })
      nil
    end

    def bring_to_front
      @channel.send_message_to_server('bringToFront')
      nil
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

    def route(url, handler, times: nil)
      entry = RouteHandler.new(url, @browser_context.send(:base_url), handler, times)
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

    def route_from_har(har, notFound: nil, update: nil, url: nil, updateContent: nil, updateMode: nil)
      if update
        @browser_context.send(:record_into_har, har, self, url: url, update_content: updateContent, update_mode: updateMode)
        return
      end

      router = HarRouter.create(
        @connection.local_utils,
        har.to_s,
        notFound || "abort",
        url_match: url,
      )
      router.add_page_route(self)
    end

    private def async_update_interception_patterns
      patterns = RouteHandler.prepare_interception_patterns(@routes)
      @channel.async_send_message_to_server('setNetworkInterceptionPatterns', patterns: patterns)
    end

    private def update_interception_patterns
      patterns = RouteHandler.prepare_interception_patterns(@routes)
      @channel.send_message_to_server('setNetworkInterceptionPatterns', patterns: patterns)
    end

    def screenshot(
      animations: nil,
      caret: nil,
      clip: nil,
      fullPage: nil,
      mask: nil,
      maskColor: nil,
      omitBackground: nil,
      path: nil,
      quality: nil,
      scale: nil,
      style: nil,
      timeout: nil,
      type: nil)

      params = {
        type: type,
        quality: quality,
        fullPage: fullPage,
        clip: clip,
        maskColor: maskColor,
        omitBackground: omitBackground,
        animations: animations,
        caret: caret,
        scale: scale,
        style: style,
        timeout: @timeout_settings.timeout(timeout),
      }.compact
      if mask.is_a?(Enumerable)
        params[:mask] = mask.map do |locator|
          locator.send(:to_protocol)
        end
      end
      encoded_binary = @channel.send_message_to_server('screenshot', params)
      decoded_binary = Base64.strict_decode64(encoded_binary)
      if path
        File.open(path, 'wb') do |f|
          f.write(decoded_binary)
        end
      end
      decoded_binary
    end

    def title
      @main_frame.title
    end

    def close(runBeforeUnload: nil, reason: nil)
      @close_reason = reason
      if @owned_context
        @owned_context.close
      else
        options = { runBeforeUnload: runBeforeUnload }.compact
        @channel.send_message_to_server('close', options)
      end
      nil
    rescue => err
      raise if !target_closed_error?(err) || !runBeforeUnload
    end

    def closed?
      @closed
    end

    def click(
          selector,
          button: nil,
          clickCount: nil,
          delay: nil,
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          strict: nil,
          timeout: nil,
          trial: nil)

      @main_frame.click(
        selector,
        button: button,
        clickCount: clickCount,
        delay: delay,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        strict: strict,
        timeout: timeout,
        trial: trial,
      )
    end

    def drag_and_drop(
          source,
          target,
          force: nil,
          noWaitAfter: nil,
          sourcePosition: nil,
          strict: nil,
          targetPosition: nil,
          timeout: nil,
          trial: nil)

      @main_frame.drag_and_drop(
        source,
        target,
        force: force,
        noWaitAfter: noWaitAfter,
        sourcePosition: sourcePosition,
        strict: strict,
        targetPosition: targetPosition,
        timeout: timeout,
        trial: trial)
    end

    def dblclick(
          selector,
          button: nil,
          delay: nil,
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          strict: nil,
          timeout: nil,
          trial: nil)
      @main_frame.dblclick(
        selector,
        button: button,
        delay: delay,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        strict: strict,
        timeout: timeout,
        trial: trial,
      )
    end

    def tap_point(
          selector,
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          strict: nil,
          timeout: nil,
          trial: nil)
      @main_frame.tap_point(
        selector,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        strict: strict,
        timeout: timeout,
        trial: trial,
      )
    end

    def fill(
      selector,
      value,
      force: nil,
      noWaitAfter: nil,
      strict: nil,
      timeout: nil)
      @main_frame.fill(
        selector,
        value,
        force: force,
        noWaitAfter: noWaitAfter,
        strict: strict,
        timeout: timeout)
    end

    def locator(
      selector,
      has: nil,
      hasNot: nil,
      hasNotText: nil,
      hasText: nil)
      @main_frame.locator(
        selector,
        has: has,
        hasNot: hasNot,
        hasNotText: hasNotText,
        hasText: hasText)
    end

    def frame_locator(selector)
      @main_frame.frame_locator(selector)
    end

    def focus(selector, strict: nil, timeout: nil)
      @main_frame.focus(selector, strict: strict, timeout: timeout)
    end

    def text_content(selector, strict: nil, timeout: nil)
      @main_frame.text_content(selector, strict: strict, timeout: timeout)
    end

    def inner_text(selector, strict: nil, timeout: nil)
      @main_frame.inner_text(selector, strict: strict, timeout: timeout)
    end

    def inner_html(selector, strict: nil, timeout: nil)
      @main_frame.inner_html(selector, strict: strict, timeout: timeout)
    end

    def get_attribute(selector, name, strict: nil, timeout: nil)
      @main_frame.get_attribute(selector, name, strict: strict, timeout: timeout)
    end

    def hover(
          selector,
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          strict: nil,
          timeout: nil,
          trial: nil)
      @main_frame.hover(
        selector,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        strict: strict,
        timeout: timeout,
        trial: trial,
      )
    end

    def select_option(
          selector,
          element: nil,
          index: nil,
          value: nil,
          label: nil,
          force: nil,
          noWaitAfter: nil,
          strict: nil,
          timeout: nil)
      @main_frame.select_option(
        selector,
        element: element,
        index: index,
        value: value,
        label: label,
        force: force,
        noWaitAfter: noWaitAfter,
        strict: strict,
        timeout: timeout,
      )
    end

    def input_value(selector, strict: nil, timeout: nil)
      @main_frame.input_value(selector, strict: strict, timeout: timeout)
    end

    def set_input_files(selector, files, noWaitAfter: nil, strict: nil,timeout: nil)
      @main_frame.set_input_files(
        selector,
        files,
        noWaitAfter: noWaitAfter,
        strict: strict,
        timeout: timeout)
    end

    def type(
      selector,
      text,
      delay: nil,
      noWaitAfter: nil,
      strict: nil,
      timeout: nil)

      @main_frame.type(
        selector,
        text,
        delay: delay,
        noWaitAfter: noWaitAfter,
        strict: strict,
        timeout: timeout)
    end

    def press(
      selector,
      key,
      delay: nil,
      noWaitAfter: nil,
      strict: nil,
      timeout: nil)

      @main_frame.press(
        selector,
        key,
        delay: delay,
        noWaitAfter: noWaitAfter,
        strict: strict,
        timeout: timeout)
    end

    def check(
      selector,
      force: nil,
      noWaitAfter: nil,
      position: nil,
      strict: nil,
      timeout: nil,
      trial: nil)

      @main_frame.check(
        selector,
        force: force,
        noWaitAfter: noWaitAfter,
        position: position,
        strict: strict,
        timeout: timeout,
        trial: trial)
    end

    def uncheck(
      selector,
      force: nil,
      noWaitAfter: nil,
      position: nil,
      strict: nil,
      timeout: nil,
      trial: nil)

      @main_frame.uncheck(
        selector,
        force: force,
        noWaitAfter: noWaitAfter,
        position: position,
        strict: strict,
        timeout: timeout,
        trial: trial)
    end

    def set_checked(selector, checked, **options)
      if checked
        check(selector, **options)
      else
        uncheck(selector, **options)
      end
    end

    def wait_for_timeout(timeout)
      @main_frame.wait_for_timeout(timeout)
    end

    def wait_for_function(pageFunction, arg: nil, polling: nil, timeout: nil)
      @main_frame.wait_for_function(pageFunction, arg: arg, polling: polling, timeout: timeout)
    end

    def workers
      @workers.to_a
    end

    def request
      @browser_context.request
    end

    def pause
      @browser_context.send(:pause)
    end

    def pdf(
          displayHeaderFooter: nil,
          footerTemplate: nil,
          format: nil,
          headerTemplate: nil,
          height: nil,
          landscape: nil,
          margin: nil,
          pageRanges: nil,
          path: nil,
          preferCSSPageSize: nil,
          printBackground: nil,
          scale: nil,
          width: nil,
          tagged: nil,
          outline: nil)

      params = {
        displayHeaderFooter: displayHeaderFooter,
        footerTemplate: footerTemplate,
        format: format,
        headerTemplate: headerTemplate,
        height: height,
        landscape: landscape,
        margin: margin,
        pageRanges: pageRanges,
        preferCSSPageSize: preferCSSPageSize,
        printBackground: printBackground,
        scale: scale,
        width: width,
        tagged: tagged,
        outline: outline,
      }.compact
      encoded_binary = @channel.send_message_to_server('pdf', params)
      decoded_binary = Base64.strict_decode64(encoded_binary)
      if path
        File.open(path, 'wb') do |f|
          f.write(decoded_binary)
        end
      end
      decoded_binary
    end

    def video
      return nil unless @browser_context.send(:has_record_video_option?)
      @video ||= Video.new(self)
    end

    def snapshot_for_ai(timeout: nil)
      @channel.send_message_to_server('snapshotForAI', timeout: @timeout_settings.timeout(timeout))
    end

    def start_js_coverage(resetOnNavigation: nil, reportAnonymousScripts: nil)
      params = {
        resetOnNavigation: resetOnNavigation,
        reportAnonymousScripts: reportAnonymousScripts,
      }.compact

      @channel.send_message_to_server('startJSCoverage', params)
    end

    def stop_js_coverage
      @channel.send_message_to_server('stopJSCoverage')
    end

    def start_css_coverage(resetOnNavigation: nil, reportAnonymousScripts: nil)
      params = {
        resetOnNavigation: resetOnNavigation,
      }.compact

      @channel.send_message_to_server('startCSSCoverage', params)
    end

    def stop_css_coverage
      @channel.send_message_to_server('stopCSSCoverage')
    end

    class CrashedError < StandardError
      def initialize
        super('Page crashed')
      end
    end

    class FrameAlreadyDetachedError < StandardError
      def initialize
        super('Navigating frame was detached!')
      end
    end

    private def close_error_with_reason
      reason = @close_reason || @browser_context.send(:effective_close_reason)
      TargetClosedError.new(message: reason)
    end

    def expect_event(event, predicate: nil, timeout: nil, &block)
      waiter = Waiter.new(self, wait_name: "Page.expect_event(#{event})")
      timeout_value = timeout || @timeout_settings.timeout
      waiter.reject_on_timeout(timeout_value, "Timeout #{timeout_value}ms exceeded while waiting for event \"#{event}\"")

      unless event == Events::Page::Crash
        waiter.reject_on_event(self, Events::Page::Crash, CrashedError.new)
      end

      unless event == Events::Page::Close
        waiter.reject_on_event(self, Events::Page::Close, -> { close_error_with_reason })
      end

      waiter.wait_for_event(self, event, predicate: predicate)
      block&.call

      waiter.result.value!
    end

    def expect_console_message(predicate: nil, timeout: nil, &block)
      expect_event(Events::Page::Console, predicate: predicate, timeout: timeout, &block)
    end

    def expect_download(predicate: nil, timeout: nil, &block)
      expect_event(Events::Page::Download, predicate: predicate, timeout: timeout, &block)
    end

    def expect_file_chooser(predicate: nil, timeout: nil, &block)
      expect_event(Events::Page::FileChooser, predicate: predicate, timeout: timeout, &block)
    end

    def expect_navigation(timeout: nil, url: nil, waitUntil: nil, &block)
      @main_frame.expect_navigation(
        timeout: timeout,
        url: url,
        waitUntil: waitUntil,
        &block)
    end

    def expect_popup(predicate: nil, timeout: nil, &block)
      expect_event(Events::Page::Popup, predicate: predicate, timeout: timeout, &block)
    end

    def expect_request(urlOrPredicate, timeout: nil, &block)
      predicate =
        case urlOrPredicate
        when String, Regexp
          url_matcher = UrlMatcher.new(urlOrPredicate, base_url: @browser_context.send(:base_url))
          -> (req){ url_matcher.match?(req.url) }
        when Proc
          urlOrPredicate
        else
          -> (_) { true }
        end

      expect_event(Events::Page::Request, predicate: predicate, timeout: timeout, &block)
    end

    def expect_request_finished(predicate: nil, timeout: nil, &block)
      expect_event(Events::Page::RequestFinished, predicate: predicate, timeout: timeout, &block)
    end

    def expect_response(urlOrPredicate, timeout: nil, &block)
      predicate =
        case urlOrPredicate
        when String, Regexp
          url_matcher = UrlMatcher.new(urlOrPredicate, base_url: @browser_context.send(:base_url))
          -> (req){ url_matcher.match?(req.url) }
        when Proc
          urlOrPredicate
        else
          -> (_) { true }
        end

      expect_event(Events::Page::Response, predicate: predicate, timeout: timeout, &block)
    end

    def expect_websocket(predicate: nil, timeout: nil, &block)
      expect_event(Events::Page::WebSocket, predicate: predicate, timeout: timeout, &block)
    end

    def expect_worker(predicate: nil, timeout: nil, &block)
      expect_event(Events::Page::Worker, predicate: predicate, timeout: timeout, &block)
    end

    # called from Frame with send(:timeout_settings)
    private def _timeout_settings
      @timeout_settings
    end

    # called from BrowserContext#expose_binding
    private def has_bindings?(name)
      @bindings.key?(name)
    end

    # called from Worker#on_close
    private def remove_worker(worker)
      @workers.delete(worker)
    end

    # called from Video
    private def remote_connection?
      @connection.remote?
    end

    # Expose guid for library developers.
    # Not intended to be used by users.
    def guid
      @guid
    end
  end
end
