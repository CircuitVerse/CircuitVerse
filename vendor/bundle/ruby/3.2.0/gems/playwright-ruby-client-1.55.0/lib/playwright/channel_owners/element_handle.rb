require_relative './js_handle'

module Playwright
  module ChannelOwners
    class ElementHandle < JSHandle
      private def _timeout(timeout)
        # @parent is Frame
        @parent.send(:_timeout, timeout)
      end

      def as_element
        self
      end

      def owner_frame
        resp = @channel.send_message_to_server('ownerFrame')
        ChannelOwners::Frame.from_nullable(resp)
      end

      def content_frame
        resp = @channel.send_message_to_server('contentFrame')
        ChannelOwners::Frame.from_nullable(resp)
      end

      def get_attribute(name)
        @channel.send_message_to_server('getAttribute', name: name)
      end

      def text_content
        @channel.send_message_to_server('textContent')
      end

      def inner_text
        @channel.send_message_to_server('innerText')
      end

      def inner_html
        @channel.send_message_to_server('innerHTML')
      end

      def checked?
        @channel.send_message_to_server('isChecked')
      end

      def disabled?
        @channel.send_message_to_server('isDisabled')
      end

      def editable?
        @channel.send_message_to_server('isEditable')
      end

      def enabled?
        @channel.send_message_to_server('isEnabled')
      end

      def hidden?
        @channel.send_message_to_server('isHidden')
      end

      def visible?
        @channel.send_message_to_server('isVisible')
      end

      def dispatch_event(type, eventInit: nil)
        params = {
          type: type,
          eventInit: JavaScript::ValueSerializer.new(eventInit).serialize,
        }.compact
        @channel.send_message_to_server('dispatchEvent', params)

        nil
      end

      def scroll_into_view_if_needed(timeout: nil)
        params = {
          timeout: _timeout(timeout),
        }.compact
        @channel.send_message_to_server('scrollIntoViewIfNeeded', params)

        nil
      end

      def hover(
            force: nil,
            modifiers: nil,
            noWaitAfter: nil,
            position: nil,
            timeout: nil,
            trial: nil)
        params = {
          force: force,
          modifiers: modifiers,
          noWaitAfter: noWaitAfter,
          position: position,
          timeout: _timeout(timeout),
          trial: trial,
        }.compact
        @channel.send_message_to_server('hover', params)

        nil
      end

      def click(
            button: nil,
            clickCount: nil,
            delay: nil,
            force: nil,
            modifiers: nil,
            noWaitAfter: nil,
            position: nil,
            timeout: nil,
            trial: nil)

        params = {
          button: button,
          clickCount: clickCount,
          delay: delay,
          force: force,
          modifiers: modifiers,
          noWaitAfter: noWaitAfter,
          position: position,
          timeout: _timeout(timeout),
          trial: trial,
        }.compact
        @channel.send_message_to_server('click', params)

        nil
      end

      def dblclick(
            button: nil,
            delay: nil,
            force: nil,
            modifiers: nil,
            noWaitAfter: nil,
            position: nil,
            timeout: nil,
            trial: nil)

        params = {
          button: button,
          delay: delay,
          force: force,
          modifiers: modifiers,
          noWaitAfter: noWaitAfter,
          position: position,
          timeout: _timeout(timeout),
          trial: trial,
        }.compact
        @channel.send_message_to_server('dblclick', params)

        nil
      end

      def select_option(
            element: nil,
            index: nil,
            value: nil,
            label: nil,
            force: nil,
            noWaitAfter: nil,
            timeout: nil)
        base_params = SelectOptionValues.new(
          element: element,
          index: index,
          value: value,
          label: label,
        ).as_params
        params = base_params.merge({ force: force, noWaitAfter: noWaitAfter, timeout: _timeout(timeout) }.compact)
        @channel.send_message_to_server('selectOption', params)
      end

      def tap_point(
            force: nil,
            modifiers: nil,
            noWaitAfter: nil,
            position: nil,
            timeout: nil,
            trial: nil)

        params = {
          force: force,
          modifiers: modifiers,
          noWaitAfter: noWaitAfter,
          position: position,
          timeout: _timeout(timeout),
          trial: trial,
        }.compact
        @channel.send_message_to_server('tap', params)

        nil
      end

      def fill(value, force: nil, noWaitAfter: nil, timeout: nil)
        params = {
          value: value,
          force: force,
          noWaitAfter: noWaitAfter,
          timeout: _timeout(timeout),
        }.compact
        @channel.send_message_to_server('fill', params)

        nil
      end

      def select_text(force: nil, timeout: nil)
        params = { force: force, timeout: _timeout(timeout) }.compact
        @channel.send_message_to_server('selectText', params)

        nil
      end

      def input_value(timeout: nil)
        params = { timeout: _timeout(timeout) }.compact
        @channel.send_message_to_server('inputValue', params)
      end

      def set_input_files(files, noWaitAfter: nil, timeout: nil)
        frame = owner_frame
        unless frame
          raise 'Cannot set input files to detached element'
        end

        method_name, params = InputFiles.new(frame.page.context, files).as_method_and_params
        params.merge!({ noWaitAfter: noWaitAfter, timeout: _timeout(timeout) }.compact)
        @channel.send_message_to_server(method_name, params)

        nil
      end

      def focus
        @channel.send_message_to_server('focus')

        nil
      end

      def type(text, delay: nil, noWaitAfter: nil, timeout: nil)
        params = {
          text: text,
          delay: delay,
          noWaitAfter: noWaitAfter,
          timeout: _timeout(timeout),
        }.compact
        @channel.send_message_to_server('type', params)

        nil
      end

      def press(key, delay: nil, noWaitAfter: nil, timeout: nil)
        params = {
          key: key,
          delay: delay,
          noWaitAfter: noWaitAfter,
          timeout: _timeout(timeout),
        }.compact
        @channel.send_message_to_server('press', params)

        nil
      end

      def check(force: nil, noWaitAfter: nil, position: nil, timeout: nil, trial: nil)
        params = {
          force: force,
          noWaitAfter:  noWaitAfter,
          position: position,
          timeout: _timeout(timeout),
          trial: trial,
        }.compact
        @channel.send_message_to_server('check', params)

        nil
      end

      def uncheck(force: nil, noWaitAfter: nil, position: nil, timeout: nil, trial: nil)
        params = {
          force: force,
          noWaitAfter:  noWaitAfter,
          position: position,
          timeout: _timeout(timeout),
          trial: trial,
        }.compact
        @channel.send_message_to_server('uncheck', params)

        nil
      end

      def set_checked(checked, **options)
        if checked
          check(**options)
        else
          uncheck(**options)
        end
      end

      def bounding_box
        @channel.send_message_to_server('boundingBox')
      end

      def screenshot(
        animations: nil,
        caret: nil,
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
          animations: animations,
          caret: caret,
          maskColor: maskColor,
          omitBackground: omitBackground,
          path: path,
          quality: quality,
          scale: scale,
          style: style,
          timeout: _timeout(timeout),
          type: type,
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

      def query_selector(selector)
        resp = @channel.send_message_to_server('querySelector', selector: selector)
        ChannelOwners::ElementHandle.from_nullable(resp)
      end

      def query_selector_all(selector)
        @channel.send_message_to_server('querySelectorAll', selector: selector).map do |el|
          ChannelOwners::ElementHandle.from(el)
        end
      end

      def eval_on_selector(selector, pageFunction, arg: nil)
        JavaScript::Expression.new(pageFunction, arg).eval_on_selector(@channel, selector)
      end

      def eval_on_selector_all(selector, pageFunction, arg: nil)
        JavaScript::Expression.new(pageFunction, arg).eval_on_selector_all(@channel, selector)
      end

      def wait_for_element_state(state, timeout: nil)
        params = { state: state, timeout: _timeout(timeout) }.compact
        @channel.send_message_to_server('waitForElementState', params)

        nil
      end

      def wait_for_selector(selector, state: nil, strict: nil, timeout: nil)
        params = { selector: selector, state: state, strict: strict, timeout: _timeout(timeout) }.compact
        resp = @channel.send_message_to_server('waitForSelector', params)

        ChannelOwners::ElementHandle.from_nullable(resp)
      end
    end
  end
end
