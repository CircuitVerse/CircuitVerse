require_relative '../locator_utils'

module Playwright
  # @ref https://github.com/microsoft/playwright-python/blob/master/playwright/_impl/_frame.py
  define_channel_owner :Frame do
    include LocatorUtils

    private def after_initialize
      if @initializer['parentFrame']
        @parent_frame = ChannelOwners::Frame.from(@initializer['parentFrame'])
        @parent_frame.send(:append_child_frame_from_child, self)
      end
      @name = @initializer['name']
      @url = @initializer['url']
      @detached = false
      @child_frames = Set.new
      @load_states = Set.new(@initializer['loadStates'])
      @event_emitter = Object.new.extend(EventEmitter)

      @channel.on('loadstate', ->(params) {
        on_load_state(add: params['add'], remove: params['remove'])
      })
      @channel.on('navigated', method(:on_frame_navigated))
    end

    attr_reader :page, :parent_frame
    attr_writer :detached

    private def _timeout(timeout)
      @page.send(:_timeout_settings).timeout(timeout)
    end

    private def _navigation_timeout(timeout)
      @page.send(:_timeout_settings).navigation_timeout(timeout)
    end

    private def on_load_state(add:, remove:)
      if add
        @load_states << add

        # Original JS version of Playwright emit event here.
        # @event_emitter.emit('loadstate', add)
      end
      if remove
        @load_states.delete(remove)
      end
      unless @parent_frame
        if add == 'load'
          @page&.emit(Events::Page::Load, @page)
        elsif add == 'domcontentloaded'
          @page&.emit(Events::Page::DOMContentLoaded, @page)
        end
      end

      # emit to waitForLoadState(load) listeners explicitly after waitForEvent(load) listeners
      if add
        @event_emitter.emit('loadstate', add)
      end
    end

    private def on_frame_navigated(event)
      @url = event['url']
      @name = event['name']
      @event_emitter.emit('navigated', event)

      unless event['error']
        @page&.emit(Events::Page::FrameNavigated, self)
      end
    end

    def goto(url, timeout: nil, waitUntil: nil, referer: nil)
      params = {
        url: url,
        timeout: _navigation_timeout(timeout),
        waitUntil: waitUntil,
        referer: referer
      }.compact
      resp = @channel.send_message_to_server('goto', params)
      ChannelOwners::Response.from_nullable(resp)
    end

    class CrashedError < StandardError
      def initialize
        super('Navigation failed because page crashed!')
      end
    end

    class FrameAlreadyDetachedError < StandardError
      def initialize
        super('Navigating frame was detached!')
      end
    end

    private def setup_navigation_waiter(wait_name:, timeout_value:)
      Waiter.new(page, wait_name: "frame.#{wait_name}").tap do |waiter|
        waiter.reject_on_event(@page, Events::Page::Close, -> { @page.send(:close_error_with_reason) })
        waiter.reject_on_event(@page, Events::Page::Crash, CrashedError.new)
        waiter.reject_on_event(@page, Events::Page::FrameDetached, FrameAlreadyDetachedError.new, predicate: -> (frame) { frame == self })
        waiter.reject_on_timeout(timeout_value, "Timeout #{timeout_value}ms exceeded.")
      end
    end

    def expect_navigation(timeout: nil, url: nil, waitUntil: nil, &block)
      option_wait_until = waitUntil || 'load'
      option_timeout = _navigation_timeout(timeout)
      time_start = Time.now

      waiter = setup_navigation_waiter(wait_name: :expect_navigation, timeout_value: option_timeout)

      to_url = url ? " to \"#{url}\"" : ''
      waiter.log("waiting for navigation#{to_url} until '#{option_wait_until}'")
      predicate =
        if url
          matcher = UrlMatcher.new(url, base_url: @page.context.send(:base_url))
          ->(event) {
            if event['error']
              true
            else
              waiter.log("  navigated to \"#{event['url']}\"")
              matcher.match?(event['url'])
            end
          }
        else
          ->(_) { true }
        end

      waiter.wait_for_event(@event_emitter, 'navigated', predicate: predicate)

      block&.call

      event = waiter.result.value!
      if event['error']
        raise event['error']
      end

      unless @load_states.include?(option_wait_until)
        elapsed_time = Time.now - time_start
        if elapsed_time < option_timeout
          wait_for_load_state(state: option_wait_until, timeout: option_timeout - elapsed_time)
        end
      end

      request_json = event.dig('newDocument', 'request')
      request = ChannelOwners::Request.from_nullable(request_json)
      request&.response
    end

    def wait_for_url(url, timeout: nil, waitUntil: nil)
      matcher = UrlMatcher.new(url, base_url: @page.context.send(:base_url))
      if matcher.match?(@url)
        wait_for_load_state(state: waitUntil, timeout: timeout)
      else
        expect_navigation(timeout: timeout, url: url, waitUntil: waitUntil)
      end
    end

    def wait_for_load_state(state: nil, timeout: nil)
      option_state = state || 'load'
      option_timeout = _navigation_timeout(timeout)
      unless %w(load domcontentloaded networkidle commit).include?(option_state)
        raise ArgumentError.new('state: expected one of (load|domcontentloaded|networkidle|commit)')
      end
      if @load_states.include?(option_state)
        return
      end

      waiter = setup_navigation_waiter(wait_name: :wait_for_load_state, timeout_value: option_timeout)

      predicate = ->(actual_state) {
        waiter.log("\"#{actual_state}\" event fired")
        actual_state == option_state
      }
      waiter.wait_for_event(@event_emitter, 'loadstate', predicate: predicate)

      # Sometimes event is already fired durting setup.
      if @load_states.include?(option_state)
        waiter.force_fulfill(option_state)
        return
      end

      waiter.result.value!

      nil
    end

    def frame_element
      resp = @channel.send_message_to_server('frameElement')
      ChannelOwners::ElementHandle.from(resp)
    end

    def evaluate(pageFunction, arg: nil)
      JavaScript::Expression.new(pageFunction, arg).evaluate(@channel)
    end

    def evaluate_handle(pageFunction, arg: nil)
      JavaScript::Expression.new(pageFunction, arg).evaluate_handle(@channel)
    end

    def query_selector(selector, strict: nil)
      params = {
        selector: selector,
        strict: strict,
      }.compact
      resp = @channel.send_message_to_server('querySelector', params)
      ChannelOwners::ElementHandle.from_nullable(resp)
    end

    def query_selector_all(selector)
      @channel.send_message_to_server('querySelectorAll', selector: selector).map do |el|
        ChannelOwners::ElementHandle.from(el)
      end
    end

    def wait_for_selector(selector, state: nil, strict: nil, timeout: nil)
      params = { selector: selector, state: state, strict: strict, timeout: _timeout(timeout) }.compact
      resp = @channel.send_message_to_server('waitForSelector', params)

      ChannelOwners::ElementHandle.from_nullable(resp)
    end

    def checked?(selector, strict: nil, timeout: nil)
      params = { selector: selector, strict: strict, timeout: _timeout(timeout) }.compact
      @channel.send_message_to_server('isChecked', params)
    end

    def disabled?(selector, strict: nil, timeout: nil)
      params = { selector: selector, strict: strict, timeout: _timeout(timeout) }.compact
      @channel.send_message_to_server('isDisabled', params)
    end

    def editable?(selector, strict: nil, timeout: nil)
      params = { selector: selector, strict: strict, timeout: _timeout(timeout) }.compact
      @channel.send_message_to_server('isEditable', params)
    end

    def enabled?(selector, strict: nil, timeout: nil)
      params = { selector: selector, strict: strict, timeout: _timeout(timeout) }.compact
      @channel.send_message_to_server('isEnabled', params)
    end

    def hidden?(selector, strict: nil, timeout: nil)
      params = { selector: selector, strict: strict, timeout: _timeout(timeout) }.compact
      @channel.send_message_to_server('isHidden', params)
    end

    def visible?(selector, strict: nil, timeout: nil)
      params = { selector: selector, strict: strict, timeout: _timeout(timeout) }.compact
      @channel.send_message_to_server('isVisible', params)
    end

    def dispatch_event(selector, type, eventInit: nil, strict: nil, timeout: nil)
      params = {
        selector: selector,
        type: type,
        eventInit: JavaScript::ValueSerializer.new(eventInit).serialize,
        strict: strict,
        timeout: _timeout(timeout),
      }.compact
      @channel.send_message_to_server('dispatchEvent', params)

      nil
    end

    def eval_on_selector(selector, pageFunction, arg: nil, strict: nil)
      JavaScript::Expression.new(pageFunction, arg).eval_on_selector(@channel, selector, strict: strict)
    end

    def eval_on_selector_all(selector, pageFunction, arg: nil)
      JavaScript::Expression.new(pageFunction, arg).eval_on_selector_all(@channel, selector)
    end

    def content
      @channel.send_message_to_server('content')
    end

    def set_content(html, timeout: nil, waitUntil: nil)
      params = {
        html: html,
        timeout: _navigation_timeout(timeout),
        waitUntil: waitUntil,
      }.compact

      @channel.send_message_to_server('setContent', params)

      nil
    end

    def name
      @name || ''
    end

    def url
      @url || ''
    end

    def child_frames
      @child_frames.to_a
    end

    def detached?
      @detached
    end

    def add_script_tag(content: nil, path: nil, type: nil, url: nil)
      params = {
        content: content,
        type: type,
        url: url,
      }.compact
      if path
        params[:content] = JavaScript::SourceUrl.new(File.read(path), path).to_s
      end
      resp = @channel.send_message_to_server('addScriptTag', params)
      ChannelOwners::ElementHandle.from(resp)
    end

    def add_style_tag(content: nil, path: nil, url: nil)
      params = {
        content: content,
        url: url,
      }.compact
      if path
        params[:content] = "#{File.read(path)}\n/*# sourceURL=#{path}*/"
      end
      resp = @channel.send_message_to_server('addStyleTag', params)
      ChannelOwners::ElementHandle.from(resp)
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

      params = {
        selector: selector,
        button: button,
        clickCount: clickCount,
        delay: delay,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        strict: strict,
        timeout: _timeout(timeout),
        trial: trial,
      }.compact
      @channel.send_message_to_server('click', params)

      nil
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

      params = {
        source: source,
        target: target,
        force: force,
        noWaitAfter: noWaitAfter,
        sourcePosition: sourcePosition,
        strict: strict,
        targetPosition: targetPosition,
        timeout: _timeout(timeout),
        trial: trial,
      }.compact
      @channel.send_message_to_server('dragAndDrop', params)

      nil
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

      params = {
        selector: selector,
        button: button,
        delay: delay,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        strict: strict,
        timeout: _timeout(timeout),
        trial: trial,
      }.compact
      @channel.send_message_to_server('dblclick', params)

      nil
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
      params = {
        selector: selector,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        strict: strict,
        timeout: _timeout(timeout),
        trial: trial,
      }.compact
      @channel.send_message_to_server('tap', params)

      nil
    end

    def fill(
          selector,
          value,
          force: nil,
          noWaitAfter: nil,
          strict: nil,
          timeout: nil)
      params = {
        selector: selector,
        value: value,
        force: force,
        noWaitAfter: noWaitAfter,
        strict: strict,
        timeout: _timeout(timeout),
      }.compact
      @channel.send_message_to_server('fill', params)

      nil
    end

    def locator(
      selector,
      has: nil,
      hasNot: nil,
      hasNotText: nil,
      hasText: nil)
      LocatorImpl.new(
        frame: self,
        selector: selector,
        has: has,
        hasNot: hasNot,
        hasNotText: hasNotText,
        hasText: hasText)
    end

    def frame_locator(selector)
      FrameLocatorImpl.new(frame: self, frame_selector: selector)
    end

    def focus(selector, strict: nil, timeout: nil)
      params = { selector: selector, strict: strict, timeout: _timeout(timeout) }.compact
      @channel.send_message_to_server('focus', params)
      nil
    end

    def text_content(selector, strict: nil, timeout: nil)
      params = { selector: selector, strict: strict, timeout: _timeout(timeout) }.compact
      @channel.send_message_to_server('textContent', params)
    end

    def inner_text(selector, strict: nil, timeout: nil)
      params = { selector: selector, strict: strict, timeout: _timeout(timeout) }.compact
      @channel.send_message_to_server('innerText', params)
    end

    def inner_html(selector, strict: nil, timeout: nil)
      params = { selector: selector, strict: strict, timeout: _timeout(timeout) }.compact
      @channel.send_message_to_server('innerHTML', params)
    end

    def get_attribute(selector, name, strict: nil, timeout: nil)
      params = {
        selector: selector,
        name: name,
        strict: strict,
        timeout: _timeout(timeout),
      }.compact
      @channel.send_message_to_server('getAttribute', params)
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
      params = {
        selector: selector,
        force: force,
        modifiers: modifiers,
        noWaitAfter: noWaitAfter,
        position: position,
        strict: strict,
        timeout: _timeout(timeout),
        trial: trial,
      }.compact
      @channel.send_message_to_server('hover', params)

      nil
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
      base_params = SelectOptionValues.new(
        element: element,
        index: index,
        value: value,
        label: label,
      ).as_params
      params = base_params.merge({ selector: selector, force: force, noWaitAfter: noWaitAfter, strict: strict, timeout: _timeout(timeout) }.compact)
      @channel.send_message_to_server('selectOption', params)
    end

    def input_value(selector, strict: nil, timeout: nil)
      params = { selector: selector, strict: strict, timeout: _timeout(timeout) }.compact
      @channel.send_message_to_server('inputValue', params)
    end

    def set_input_files(selector, files, noWaitAfter: nil, strict: nil, timeout: nil)
      method_name, params = InputFiles.new(page.context, files).as_method_and_params
      params.merge!({
        selector: selector,
        noWaitAfter: noWaitAfter,
        strict: strict,
        timeout: _timeout(timeout),
      }.compact)
      @channel.send_message_to_server(method_name, params)

      nil
    end

    def type(
          selector,
          text,
          delay: nil,
          noWaitAfter: nil,
          strict: nil,
          timeout: nil)

      params = {
        selector: selector,
        text: text,
        delay: delay,
        noWaitAfter: noWaitAfter,
        strict: strict,
        timeout: _timeout(timeout),
      }.compact
      @channel.send_message_to_server('type', params)

      nil
    end

    def press(
          selector,
          key,
          delay: nil,
          noWaitAfter: nil,
          strict: nil,
          timeout: nil)

      params = {
        selector: selector,
        key: key,
        delay: delay,
        noWaitAfter: noWaitAfter,
        strict: strict,
        timeout: _timeout(timeout),
      }.compact
      @channel.send_message_to_server('press', params)

      nil
    end

    def check(
      selector,
      force: nil,
      noWaitAfter: nil,
      position: nil,
      strict: nil,
      timeout: nil,
      trial: nil)

      params = {
        selector: selector,
        force: force,
        noWaitAfter:  noWaitAfter,
        position: position,
        strict: strict,
        timeout: _timeout(timeout),
        trial: trial,
      }.compact
      @channel.send_message_to_server('check', params)

      nil
    end

    def uncheck(
      selector,
      force: nil,
      noWaitAfter: nil,
      position: nil,
      strict: nil,
      timeout: nil,
      trial: nil)

      params = {
        selector: selector,
        force: force,
        noWaitAfter:  noWaitAfter,
        position: position,
        strict: strict,
        timeout: _timeout(timeout),
        trial: trial,
      }.compact
      @channel.send_message_to_server('uncheck', params)

      nil
    end

    def set_checked(selector, checked, **options)
      if checked
        check(selector, **options)
      else
        uncheck(selector, **options)
      end
    end

    def wait_for_timeout(timeout)
      @channel.send_message_to_server('waitForTimeout', waitTimeout: timeout)

      nil
    end

    def wait_for_function(pageFunction, arg: nil, polling: nil, timeout: nil)
      if polling.is_a?(String) && polling != 'raf'
        raise ArgumentError.new("Unknown polling option: #{polling}")
      end

      expression = JavaScript::Expression.new(pageFunction, arg)
      expression.wait_for_function(@channel, polling: polling, timeout: _timeout(timeout))
    end

    def title
      @channel.send_message_to_server('title')
    end

    def highlight(selector)
      @channel.send_message_to_server('highlight', selector: selector)
    end

    def expect(selector, expression, options, title)
      if options.key?(:expectedValue)
        options[:expectedValue] = JavaScript::ValueSerializer
          .new(options[:expectedValue])
          .serialize
      end

      result = @channel.send_message_to_server_result(
        title, # title
        "expect", # method
        { # params
          selector: selector,
          expression: expression,
          **options,
        }.compact
      )

      if result.key?('received')
        result['received'] = JavaScript::ValueParser.new(result['received']).parse
      end

      result
    end

    # @param page [Page]
    # @note This method should be used internally. Accessed via .send method, so keep private!
    private def update_page_from_page(page)
      @page = page
    end

    # @param child [Frame]
    # @note This method should be used internally. Accessed via .send method, so keep private!
    private def append_child_frame_from_child(frame)
      @child_frames << frame
    end
  end
end
