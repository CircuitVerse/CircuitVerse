require_relative './js_handle.rb'

module Playwright
  # - extends: `JSHandle`
  #
  # ElementHandle represents an in-page DOM element. ElementHandles can be created with the [`method: Page.querySelector`] method.
  #
  # **NOTE**: The use of ElementHandle is discouraged, use `Locator` objects and web-first assertions instead.
  #
  # ```python sync
  # href_element = page.query_selector("a")
  # href_element.click()
  # ```
  #
  # ElementHandle prevents DOM element from garbage collection unless the handle is disposed with
  # [`method: JSHandle.dispose`]. ElementHandles are auto-disposed when their origin frame gets navigated.
  #
  # ElementHandle instances can be used as an argument in [`method: Page.evalOnSelector`] and [`method: Page.evaluate`] methods.
  #
  # The difference between the `Locator` and ElementHandle is that the ElementHandle points to a particular element, while `Locator` captures the logic of how to retrieve an element.
  #
  # In the example below, handle points to a particular DOM element on page. If that element changes text or is used by React to render an entirely different component, handle is still pointing to that very DOM element. This can lead to unexpected behaviors.
  #
  # ```python sync
  # handle = page.query_selector("text=Submit")
  # handle.hover()
  # handle.click()
  # ```
  #
  # With the locator, every time the `element` is used, up-to-date DOM element is located in the page using the selector. So in the snippet below, underlying DOM element is going to be located twice.
  #
  # ```python sync
  # locator = page.get_by_text("Submit")
  # locator.hover()
  # locator.click()
  # ```
  class ElementHandle < JSHandle

    #
    # This method returns the bounding box of the element, or `null` if the element is not visible. The bounding box is
    # calculated relative to the main frame viewport - which is usually the same as the browser window.
    #
    # Scrolling affects the returned bounding box, similarly to
    # [Element.getBoundingClientRect](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect). That
    # means `x` and/or `y` may be negative.
    #
    # Elements from child frames return the bounding box relative to the main frame, unlike the
    # [Element.getBoundingClientRect](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect).
    #
    # Assuming the page is static, it is safe to use bounding box coordinates to perform input. For example, the following
    # snippet should click the center of the element.
    #
    # **Usage**
    #
    # ```python sync
    # box = element_handle.bounding_box()
    # page.mouse.click(box["x"] + box["width"] / 2, box["y"] + box["height"] / 2)
    # ```
    def bounding_box
      wrap_impl(@impl.bounding_box)
    end

    #
    # This method checks the element by performing the following steps:
    # 1. Ensure that element is a checkbox or a radio input. If not, this method throws. If the element is already checked, this method returns immediately.
    # 1. Wait for [actionability](../actionability.md) checks on the element, unless `force` option is set.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to click in the center of the element.
    # 1. Ensure that the element is now checked. If not, this method throws.
    #
    # If the element is detached from the DOM at any moment during the action, this method throws.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a
    # `TimeoutError`. Passing zero timeout disables this.
    def check(
          force: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.check(force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    #
    # This method clicks the element by performing the following steps:
    # 1. Wait for [actionability](../actionability.md) checks on the element, unless `force` option is set.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to click in the center of the element, or the specified `position`.
    # 1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
    #
    # If the element is detached from the DOM at any moment during the action, this method throws.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a
    # `TimeoutError`. Passing zero timeout disables this.
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
      wrap_impl(@impl.click(button: unwrap_impl(button), clickCount: unwrap_impl(clickCount), delay: unwrap_impl(delay), force: unwrap_impl(force), modifiers: unwrap_impl(modifiers), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    #
    # Returns the content frame for element handles referencing iframe nodes, or `null` otherwise
    def content_frame
      wrap_impl(@impl.content_frame)
    end

    #
    # This method double clicks the element by performing the following steps:
    # 1. Wait for [actionability](../actionability.md) checks on the element, unless `force` option is set.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to double click in the center of the element, or the specified `position`.
    #
    # If the element is detached from the DOM at any moment during the action, this method throws.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a
    # `TimeoutError`. Passing zero timeout disables this.
    #
    # **NOTE**: `elementHandle.dblclick()` dispatches two `click` events and a single `dblclick` event.
    def dblclick(
          button: nil,
          delay: nil,
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.dblclick(button: unwrap_impl(button), delay: unwrap_impl(delay), force: unwrap_impl(force), modifiers: unwrap_impl(modifiers), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    #
    # The snippet below dispatches the `click` event on the element. Regardless of the visibility state of the element, `click`
    # is dispatched. This is equivalent to calling
    # [element.click()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/click).
    #
    # **Usage**
    #
    # ```python sync
    # element_handle.dispatch_event("click")
    # ```
    #
    # Under the hood, it creates an instance of an event based on the given `type`, initializes it with
    # `eventInit` properties and dispatches it on the element. Events are `composed`, `cancelable` and bubble by
    # default.
    #
    # Since `eventInit` is event-specific, please refer to the events documentation for the lists of initial
    # properties:
    # - [DeviceMotionEvent](https://developer.mozilla.org/en-US/docs/Web/API/DeviceMotionEvent/DeviceMotionEvent)
    # - [DeviceOrientationEvent](https://developer.mozilla.org/en-US/docs/Web/API/DeviceOrientationEvent/DeviceOrientationEvent)
    # - [DragEvent](https://developer.mozilla.org/en-US/docs/Web/API/DragEvent/DragEvent)
    # - [Event](https://developer.mozilla.org/en-US/docs/Web/API/Event/Event)
    # - [FocusEvent](https://developer.mozilla.org/en-US/docs/Web/API/FocusEvent/FocusEvent)
    # - [KeyboardEvent](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/KeyboardEvent)
    # - [MouseEvent](https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent/MouseEvent)
    # - [PointerEvent](https://developer.mozilla.org/en-US/docs/Web/API/PointerEvent/PointerEvent)
    # - [TouchEvent](https://developer.mozilla.org/en-US/docs/Web/API/TouchEvent/TouchEvent)
    # - [WheelEvent](https://developer.mozilla.org/en-US/docs/Web/API/WheelEvent/WheelEvent)
    #
    # You can also specify `JSHandle` as the property value if you want live objects to be passed into the event:
    #
    # ```python sync
    # # note you can only create data_transfer in chromium and firefox
    # data_transfer = page.evaluate_handle("new DataTransfer()")
    # element_handle.dispatch_event("#source", "dragstart", {"dataTransfer": data_transfer})
    # ```
    def dispatch_event(type, eventInit: nil)
      wrap_impl(@impl.dispatch_event(unwrap_impl(type), eventInit: unwrap_impl(eventInit)))
    end

    #
    # Returns the return value of `expression`.
    #
    # The method finds an element matching the specified selector in the `ElementHandle`s subtree and passes it as a first
    # argument to `expression`. If no elements match the selector, the method throws an error.
    #
    # If `expression` returns a [Promise], then [`method: ElementHandle.evalOnSelector`] would wait for the promise to resolve and return its
    # value.
    #
    # **Usage**
    #
    # ```python sync
    # tweet_handle = page.query_selector(".tweet")
    # assert tweet_handle.eval_on_selector(".like", "node => node.innerText") == "100"
    # assert tweet_handle.eval_on_selector(".retweets", "node => node.innerText") == "10"
    # ```
    def eval_on_selector(selector, expression, arg: nil)
      wrap_impl(@impl.eval_on_selector(unwrap_impl(selector), unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    #
    # Returns the return value of `expression`.
    #
    # The method finds all elements matching the specified selector in the `ElementHandle`'s subtree and passes an array of
    # matched elements as a first argument to `expression`.
    #
    # If `expression` returns a [Promise], then [`method: ElementHandle.evalOnSelectorAll`] would wait for the promise to resolve and return its
    # value.
    #
    # **Usage**
    #
    # ```html
    # <div class="feed">
    #   <div class="tweet">Hello!</div>
    #   <div class="tweet">Hi!</div>
    # </div>
    # ```
    #
    # ```python sync
    # feed_handle = page.query_selector(".feed")
    # assert feed_handle.eval_on_selector_all(".tweet", "nodes => nodes.map(n => n.innerText)") == ["hello!", "hi!"]
    # ```
    def eval_on_selector_all(selector, expression, arg: nil)
      wrap_impl(@impl.eval_on_selector_all(unwrap_impl(selector), unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    #
    # This method waits for [actionability](../actionability.md) checks, focuses the element, fills it and triggers an `input` event after filling. Note that you can pass an empty string to clear the input field.
    #
    # If the target element is not an `<input>`, `<textarea>` or `[contenteditable]` element, this method throws an error. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be filled instead.
    #
    # To send fine-grained keyboard events, use [`method: Locator.pressSequentially`].
    def fill(value, force: nil, noWaitAfter: nil, timeout: nil)
      wrap_impl(@impl.fill(unwrap_impl(value), force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    #
    # Calls [focus](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/focus) on the element.
    def focus
      wrap_impl(@impl.focus)
    end

    #
    # Returns element attribute value.
    def get_attribute(name)
      wrap_impl(@impl.get_attribute(unwrap_impl(name)))
    end
    alias_method :[], :get_attribute

    #
    # This method hovers over the element by performing the following steps:
    # 1. Wait for [actionability](../actionability.md) checks on the element, unless `force` option is set.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to hover over the center of the element, or the specified `position`.
    #
    # If the element is detached from the DOM at any moment during the action, this method throws.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a
    # `TimeoutError`. Passing zero timeout disables this.
    def hover(
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.hover(force: unwrap_impl(force), modifiers: unwrap_impl(modifiers), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    #
    # Returns the `element.innerHTML`.
    def inner_html
      wrap_impl(@impl.inner_html)
    end

    #
    # Returns the `element.innerText`.
    def inner_text
      wrap_impl(@impl.inner_text)
    end

    #
    # Returns `input.value` for the selected `<input>` or `<textarea>` or `<select>` element.
    #
    # Throws for non-input elements. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), returns the value of the control.
    def input_value(timeout: nil)
      wrap_impl(@impl.input_value(timeout: unwrap_impl(timeout)))
    end

    #
    # Returns whether the element is checked. Throws if the element is not a checkbox or radio input.
    def checked?
      wrap_impl(@impl.checked?)
    end

    #
    # Returns whether the element is disabled, the opposite of [enabled](../actionability.md#enabled).
    def disabled?
      wrap_impl(@impl.disabled?)
    end

    #
    # Returns whether the element is [editable](../actionability.md#editable).
    def editable?
      wrap_impl(@impl.editable?)
    end

    #
    # Returns whether the element is [enabled](../actionability.md#enabled).
    def enabled?
      wrap_impl(@impl.enabled?)
    end

    #
    # Returns whether the element is hidden, the opposite of [visible](../actionability.md#visible).
    def hidden?
      wrap_impl(@impl.hidden?)
    end

    #
    # Returns whether the element is [visible](../actionability.md#visible).
    def visible?
      wrap_impl(@impl.visible?)
    end

    #
    # Returns the frame containing the given element.
    def owner_frame
      wrap_impl(@impl.owner_frame)
    end

    #
    # Focuses the element, and then uses [`method: Keyboard.down`] and [`method: Keyboard.up`].
    #
    # `key` can specify the intended
    # [keyboardEvent.key](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key) value or a single character to
    # generate the text for. A superset of the `key` values can be found
    # [here](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values). Examples of the keys are:
    #
    # `F1` - `F12`, `Digit0`- `Digit9`, `KeyA`- `KeyZ`, `Backquote`, `Minus`, `Equal`, `Backslash`, `Backspace`, `Tab`,
    # `Delete`, `Escape`, `ArrowDown`, `End`, `Enter`, `Home`, `Insert`, `PageDown`, `PageUp`, `ArrowRight`, `ArrowUp`, etc.
    #
    # Following modification shortcuts are also supported: `Shift`, `Control`, `Alt`, `Meta`, `ShiftLeft`, `ControlOrMeta`.
    #
    # Holding down `Shift` will type the text that corresponds to the `key` in the upper case.
    #
    # If `key` is a single character, it is case-sensitive, so the values `a` and `A` will generate different
    # respective texts.
    #
    # Shortcuts such as `key: "Control+o"`, `key: "Control++` or `key: "Control+Shift+T"` are supported as well. When specified with the
    # modifier, modifier is pressed and being held while the subsequent key is being pressed.
    def press(key, delay: nil, noWaitAfter: nil, timeout: nil)
      wrap_impl(@impl.press(unwrap_impl(key), delay: unwrap_impl(delay), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    #
    # The method finds an element matching the specified selector in the `ElementHandle`'s subtree. If no elements match the selector,
    # returns `null`.
    def query_selector(selector)
      wrap_impl(@impl.query_selector(unwrap_impl(selector)))
    end

    #
    # The method finds all elements matching the specified selector in the `ElementHandle`s subtree. If no elements match the selector,
    # returns empty array.
    def query_selector_all(selector)
      wrap_impl(@impl.query_selector_all(unwrap_impl(selector)))
    end

    #
    # This method captures a screenshot of the page, clipped to the size and position of this particular element. If the element is covered by other elements, it will not be actually visible on the screenshot. If the element is a scrollable container, only the currently scrolled content will be visible on the screenshot.
    #
    # This method waits for the [actionability](../actionability.md) checks, then scrolls element into view before taking a
    # screenshot. If the element is detached from DOM, the method throws an error.
    #
    # Returns the buffer with the captured screenshot.
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
      wrap_impl(@impl.screenshot(animations: unwrap_impl(animations), caret: unwrap_impl(caret), mask: unwrap_impl(mask), maskColor: unwrap_impl(maskColor), omitBackground: unwrap_impl(omitBackground), path: unwrap_impl(path), quality: unwrap_impl(quality), scale: unwrap_impl(scale), style: unwrap_impl(style), timeout: unwrap_impl(timeout), type: unwrap_impl(type)))
    end

    #
    # This method waits for [actionability](../actionability.md) checks, then tries to scroll element into view, unless it is
    # completely visible as defined by
    # [IntersectionObserver](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API)'s `ratio`.
    #
    # Throws when `elementHandle` does not point to an element
    # [connected](https://developer.mozilla.org/en-US/docs/Web/API/Node/isConnected) to a Document or a ShadowRoot.
    #
    # See [scrolling](../input.md#scrolling) for alternative ways to scroll.
    def scroll_into_view_if_needed(timeout: nil)
      wrap_impl(@impl.scroll_into_view_if_needed(timeout: unwrap_impl(timeout)))
    end

    #
    # This method waits for [actionability](../actionability.md) checks, waits until all specified options are present in the `<select>` element and selects these options.
    #
    # If the target element is not a `<select>` element, this method throws an error. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be used instead.
    #
    # Returns the array of option values that have been successfully selected.
    #
    # Triggers a `change` and `input` event once all the provided options have been selected.
    #
    # **Usage**
    #
    # ```python sync
    # # Single selection matching the value or label
    # handle.select_option("blue")
    # # single selection matching both the label
    # handle.select_option(label="blue")
    # # multiple selection
    # handle.select_option(value=["red", "green", "blue"])
    # ```
    def select_option(
          element: nil,
          index: nil,
          value: nil,
          label: nil,
          force: nil,
          noWaitAfter: nil,
          timeout: nil)
      wrap_impl(@impl.select_option(element: unwrap_impl(element), index: unwrap_impl(index), value: unwrap_impl(value), label: unwrap_impl(label), force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    #
    # This method waits for [actionability](../actionability.md) checks, then focuses the element and selects all its text
    # content.
    #
    # If the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), focuses and selects text in the control instead.
    def select_text(force: nil, timeout: nil)
      wrap_impl(@impl.select_text(force: unwrap_impl(force), timeout: unwrap_impl(timeout)))
    end

    #
    # This method checks or unchecks an element by performing the following steps:
    # 1. Ensure that element is a checkbox or a radio input. If not, this method throws.
    # 1. If the element already has the right checked state, this method returns immediately.
    # 1. Wait for [actionability](../actionability.md) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to click in the center of the element.
    # 1. Ensure that the element is now checked or unchecked. If not, this method throws.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a
    # `TimeoutError`. Passing zero timeout disables this.
    def set_checked(
          checked,
          force: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.set_checked(unwrap_impl(checked), force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end
    alias_method :checked=, :set_checked

    #
    # Sets the value of the file input to these file paths or files. If some of the `filePaths` are relative paths, then they
    # are resolved relative to the current working directory. For empty array, clears the selected files.
    # For inputs with a `[webkitdirectory]` attribute, only a single directory path is supported.
    #
    # This method expects `ElementHandle` to point to an
    # [input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input). However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), targets the control instead.
    def set_input_files(files, noWaitAfter: nil, timeout: nil)
      wrap_impl(@impl.set_input_files(unwrap_impl(files), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end
    alias_method :input_files=, :set_input_files

    #
    # This method taps the element by performing the following steps:
    # 1. Wait for [actionability](../actionability.md) checks on the element, unless `force` option is set.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.touchscreen`] to tap the center of the element, or the specified `position`.
    #
    # If the element is detached from the DOM at any moment during the action, this method throws.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a
    # `TimeoutError`. Passing zero timeout disables this.
    #
    # **NOTE**: `elementHandle.tap()` requires that the `hasTouch` option of the browser context be set to true.
    def tap_point(
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.tap_point(force: unwrap_impl(force), modifiers: unwrap_impl(modifiers), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    #
    # Returns the `node.textContent`.
    def text_content
      wrap_impl(@impl.text_content)
    end

    #
    # Focuses the element, and then sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text.
    #
    # To press a special key, like `Control` or `ArrowDown`, use [`method: ElementHandle.press`].
    #
    # **Usage**
    #
    # @deprecated In most cases, you should use [`method: Locator.fill`] instead. You only need to press keys one by one if there is special keyboard handling on the page - in this case use [`method: Locator.pressSequentially`].
    def type(text, delay: nil, noWaitAfter: nil, timeout: nil)
      wrap_impl(@impl.type(unwrap_impl(text), delay: unwrap_impl(delay), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    #
    # This method checks the element by performing the following steps:
    # 1. Ensure that element is a checkbox or a radio input. If not, this method throws. If the element is already unchecked, this method returns immediately.
    # 1. Wait for [actionability](../actionability.md) checks on the element, unless `force` option is set.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to click in the center of the element.
    # 1. Ensure that the element is now unchecked. If not, this method throws.
    #
    # If the element is detached from the DOM at any moment during the action, this method throws.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a
    # `TimeoutError`. Passing zero timeout disables this.
    def uncheck(
          force: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.uncheck(force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    #
    # Returns when the element satisfies the `state`.
    #
    # Depending on the `state` parameter, this method waits for one of the [actionability](../actionability.md) checks
    # to pass. This method throws when the element is detached while waiting, unless waiting for the `"hidden"` state.
    # - `"visible"` Wait until the element is [visible](../actionability.md#visible).
    # - `"hidden"` Wait until the element is [not visible](../actionability.md#visible) or not attached. Note that waiting for hidden does not throw when the element detaches.
    # - `"stable"` Wait until the element is both [visible](../actionability.md#visible) and [stable](../actionability.md#stable).
    # - `"enabled"` Wait until the element is [enabled](../actionability.md#enabled).
    # - `"disabled"` Wait until the element is [not enabled](../actionability.md#enabled).
    # - `"editable"` Wait until the element is [editable](../actionability.md#editable).
    #
    # If the element does not satisfy the condition for the `timeout` milliseconds, this method will throw.
    def wait_for_element_state(state, timeout: nil)
      wrap_impl(@impl.wait_for_element_state(unwrap_impl(state), timeout: unwrap_impl(timeout)))
    end

    #
    # Returns element specified by selector when it satisfies `state` option. Returns `null` if waiting for `hidden`
    # or `detached`.
    #
    # Wait for the `selector` relative to the element handle to satisfy `state` option (either
    # appear/disappear from dom, or become visible/hidden). If at the moment of calling the method `selector` already
    # satisfies the condition, the method will return immediately. If the selector doesn't satisfy the condition for the
    # `timeout` milliseconds, the function will throw.
    #
    # **Usage**
    #
    # ```python sync
    # page.set_content("<div><span></span></div>")
    # div = page.query_selector("div")
    # # waiting for the "span" selector relative to the div.
    # span = div.wait_for_selector("span", state="attached")
    # ```
    #
    # **NOTE**: This method does not work across navigations, use [`method: Page.waitForSelector`] instead.
    def wait_for_selector(selector, state: nil, strict: nil, timeout: nil)
      wrap_impl(@impl.wait_for_selector(unwrap_impl(selector), state: unwrap_impl(state), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def once(event, callback)
      event_emitter_proxy.once(event, callback)
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def on(event, callback)
      event_emitter_proxy.on(event, callback)
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def off(event, callback)
      event_emitter_proxy.off(event, callback)
    end

    private def event_emitter_proxy
      @event_emitter_proxy ||= EventEmitterProxy.new(self, @impl)
    end
  end
end
