module Playwright
  #
  # At every point of time, page exposes its current frame tree via the [`method: Page.mainFrame`] and
  # [`method: Frame.childFrames`] methods.
  #
  # `Frame` object's lifecycle is controlled by three events, dispatched on the page object:
  # - [`event: Page.frameAttached`] - fired when the frame gets attached to the page. A Frame can be attached to the page only once.
  # - [`event: Page.frameNavigated`] - fired when the frame commits navigation to a different URL.
  # - [`event: Page.frameDetached`] - fired when the frame gets detached from the page.  A Frame can be detached from the page only once.
  #
  # An example of dumping frame tree:
  #
  # ```python sync
  # from playwright.sync_api import sync_playwright, Playwright
  #
  # def run(playwright: Playwright):
  #     firefox = playwright.firefox
  #     browser = firefox.launch()
  #     page = browser.new_page()
  #     page.goto("https://www.theverge.com")
  #     dump_frame_tree(page.main_frame, "")
  #     browser.close()
  #
  # def dump_frame_tree(frame, indent):
  #     print(indent + frame.name + '@' + frame.url)
  #     for child in frame.child_frames:
  #         dump_frame_tree(child, indent + "    ")
  #
  # with sync_playwright() as playwright:
  #     run(playwright)
  # ```
  class Frame < PlaywrightApi

    #
    # Returns the added tag when the script's onload fires or when the script content was injected into frame.
    #
    # Adds a `<script>` tag into the page with the desired url or content.
    def add_script_tag(content: nil, path: nil, type: nil, url: nil)
      wrap_impl(@impl.add_script_tag(content: unwrap_impl(content), path: unwrap_impl(path), type: unwrap_impl(type), url: unwrap_impl(url)))
    end

    #
    # Returns the added tag when the stylesheet's onload fires or when the CSS content was injected into frame.
    #
    # Adds a `<link rel="stylesheet">` tag into the page with the desired url or a `<style type="text/css">` tag with the
    # content.
    def add_style_tag(content: nil, path: nil, url: nil)
      wrap_impl(@impl.add_style_tag(content: unwrap_impl(content), path: unwrap_impl(path), url: unwrap_impl(url)))
    end

    #
    # This method checks an element matching `selector` by performing the following steps:
    # 1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
    # 1. Ensure that matched element is a checkbox or a radio input. If not, this method throws. If the element is already checked, this method returns immediately.
    # 1. Wait for [actionability](../actionability.md) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to click in the center of the element.
    # 1. Ensure that the element is now checked. If not, this method throws.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a
    # `TimeoutError`. Passing zero timeout disables this.
    def check(
          selector,
          force: nil,
          noWaitAfter: nil,
          position: nil,
          strict: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.check(unwrap_impl(selector), force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    def child_frames
      wrap_impl(@impl.child_frames)
    end

    #
    # This method clicks an element matching `selector` by performing the following steps:
    # 1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
    # 1. Wait for [actionability](../actionability.md) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to click in the center of the element, or the specified `position`.
    # 1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a
    # `TimeoutError`. Passing zero timeout disables this.
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
      wrap_impl(@impl.click(unwrap_impl(selector), button: unwrap_impl(button), clickCount: unwrap_impl(clickCount), delay: unwrap_impl(delay), force: unwrap_impl(force), modifiers: unwrap_impl(modifiers), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    #
    # Gets the full HTML contents of the frame, including the doctype.
    def content
      wrap_impl(@impl.content)
    end

    #
    # This method double clicks an element matching `selector` by performing the following steps:
    # 1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
    # 1. Wait for [actionability](../actionability.md) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to double click in the center of the element, or the specified `position`. if the first click of the `dblclick()` triggers a navigation event, this method will throw.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a
    # `TimeoutError`. Passing zero timeout disables this.
    #
    # **NOTE**: `frame.dblclick()` dispatches two `click` events and a single `dblclick` event.
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
      wrap_impl(@impl.dblclick(unwrap_impl(selector), button: unwrap_impl(button), delay: unwrap_impl(delay), force: unwrap_impl(force), modifiers: unwrap_impl(modifiers), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    #
    # The snippet below dispatches the `click` event on the element. Regardless of the visibility state of the element, `click`
    # is dispatched. This is equivalent to calling
    # [element.click()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/click).
    #
    # **Usage**
    #
    # ```python sync
    # frame.dispatch_event("button#submit", "click")
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
    # data_transfer = frame.evaluate_handle("new DataTransfer()")
    # frame.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })
    # ```
    def dispatch_event(
          selector,
          type,
          eventInit: nil,
          strict: nil,
          timeout: nil)
      wrap_impl(@impl.dispatch_event(unwrap_impl(selector), unwrap_impl(type), eventInit: unwrap_impl(eventInit), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
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
      wrap_impl(@impl.drag_and_drop(unwrap_impl(source), unwrap_impl(target), force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), sourcePosition: unwrap_impl(sourcePosition), strict: unwrap_impl(strict), targetPosition: unwrap_impl(targetPosition), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    #
    # Returns the return value of `expression`.
    #
    # The method finds an element matching the specified selector within the frame and passes it as a first argument to
    # `expression`. If no
    # elements match the selector, the method throws an error.
    #
    # If `expression` returns a [Promise], then [`method: Frame.evalOnSelector`] would wait for the promise to resolve and return its
    # value.
    #
    # **Usage**
    #
    # ```python sync
    # search_value = frame.eval_on_selector("#search", "el => el.value")
    # preload_href = frame.eval_on_selector("link[rel=preload]", "el => el.href")
    # html = frame.eval_on_selector(".main-container", "(e, suffix) => e.outerHTML + suffix", "hello")
    # ```
    def eval_on_selector(selector, expression, arg: nil, strict: nil)
      wrap_impl(@impl.eval_on_selector(unwrap_impl(selector), unwrap_impl(expression), arg: unwrap_impl(arg), strict: unwrap_impl(strict)))
    end

    #
    # Returns the return value of `expression`.
    #
    # The method finds all elements matching the specified selector within the frame and passes an array of matched elements
    # as a first argument to `expression`.
    #
    # If `expression` returns a [Promise], then [`method: Frame.evalOnSelectorAll`] would wait for the promise to resolve and return its
    # value.
    #
    # **Usage**
    #
    # ```python sync
    # divs_counts = frame.eval_on_selector_all("div", "(divs, min) => divs.length >= min", 10)
    # ```
    def eval_on_selector_all(selector, expression, arg: nil)
      wrap_impl(@impl.eval_on_selector_all(unwrap_impl(selector), unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    #
    # Returns the return value of `expression`.
    #
    # If the function passed to the [`method: Frame.evaluate`] returns a [Promise], then [`method: Frame.evaluate`] would wait for the promise to
    # resolve and return its value.
    #
    # If the function passed to the [`method: Frame.evaluate`] returns a non-[Serializable] value, then
    # [`method: Frame.evaluate`] returns `undefined`. Playwright also supports transferring some
    # additional values that are not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`.
    #
    # **Usage**
    #
    # ```python sync
    # result = frame.evaluate("([x, y]) => Promise.resolve(x * y)", [7, 8])
    # print(result) # prints "56"
    # ```
    #
    # A string can also be passed in instead of a function.
    #
    # ```python sync
    # print(frame.evaluate("1 + 2")) # prints "3"
    # x = 10
    # print(frame.evaluate(f"1 + {x}")) # prints "11"
    # ```
    #
    # `ElementHandle` instances can be passed as an argument to the [`method: Frame.evaluate`]:
    #
    # ```python sync
    # body_handle = frame.evaluate("document.body")
    # html = frame.evaluate("([body, suffix]) => body.innerHTML + suffix", [body_handle, "hello"])
    # body_handle.dispose()
    # ```
    def evaluate(expression, arg: nil)
      wrap_impl(@impl.evaluate(unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    #
    # Returns the return value of `expression` as a `JSHandle`.
    #
    # The only difference between [`method: Frame.evaluate`] and [`method: Frame.evaluateHandle`] is that
    # [`method: Frame.evaluateHandle`] returns `JSHandle`.
    #
    # If the function, passed to the [`method: Frame.evaluateHandle`], returns a [Promise], then
    # [`method: Frame.evaluateHandle`] would wait for the promise to resolve and return its value.
    #
    # **Usage**
    #
    # ```python sync
    # a_window_handle = frame.evaluate_handle("Promise.resolve(window)")
    # a_window_handle # handle for the window object.
    # ```
    #
    # A string can also be passed in instead of a function.
    #
    # ```python sync
    # a_handle = page.evaluate_handle("document") # handle for the "document"
    # ```
    #
    # `JSHandle` instances can be passed as an argument to the [`method: Frame.evaluateHandle`]:
    #
    # ```python sync
    # a_handle = page.evaluate_handle("document.body")
    # result_handle = page.evaluate_handle("body => body.innerHTML", a_handle)
    # print(result_handle.json_value())
    # result_handle.dispose()
    # ```
    def evaluate_handle(expression, arg: nil)
      wrap_impl(@impl.evaluate_handle(unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    #
    # This method waits for an element matching `selector`, waits for [actionability](../actionability.md) checks, focuses the element, fills it and triggers an `input` event after filling. Note that you can pass an empty string to clear the input field.
    #
    # If the target element is not an `<input>`, `<textarea>` or `[contenteditable]` element, this method throws an error. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be filled instead.
    #
    # To send fine-grained keyboard events, use [`method: Locator.pressSequentially`].
    def fill(
          selector,
          value,
          force: nil,
          noWaitAfter: nil,
          strict: nil,
          timeout: nil)
      wrap_impl(@impl.fill(unwrap_impl(selector), unwrap_impl(value), force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # This method fetches an element with `selector` and focuses it. If there's no element matching
    # `selector`, the method waits until a matching element appears in the DOM.
    def focus(selector, strict: nil, timeout: nil)
      wrap_impl(@impl.focus(unwrap_impl(selector), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # Returns the `frame` or `iframe` element handle which corresponds to this frame.
    #
    # This is an inverse of [`method: ElementHandle.contentFrame`]. Note that returned handle actually belongs to the parent
    # frame.
    #
    # This method throws an error if the frame has been detached before `frameElement()` returns.
    #
    # **Usage**
    #
    # ```python sync
    # frame_element = frame.frame_element()
    # content_frame = frame_element.content_frame()
    # assert frame == content_frame
    # ```
    def frame_element
      wrap_impl(@impl.frame_element)
    end

    #
    # When working with iframes, you can create a frame locator that will enter the iframe and allow selecting elements
    # in that iframe.
    #
    # **Usage**
    #
    # Following snippet locates element with text "Submit" in the iframe with id `my-frame`, like `<iframe id="my-frame">`:
    #
    # ```python sync
    # locator = frame.frame_locator("#my-iframe").get_by_text("Submit")
    # locator.click()
    # ```
    def frame_locator(selector)
      wrap_impl(@impl.frame_locator(unwrap_impl(selector)))
    end

    #
    # Returns element attribute value.
    def get_attribute(selector, name, strict: nil, timeout: nil)
      wrap_impl(@impl.get_attribute(unwrap_impl(selector), unwrap_impl(name), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # Allows locating elements by their alt text.
    #
    # **Usage**
    #
    # For example, this method will find the image by alt text "Playwright logo":
    #
    # ```html
    # <img alt='Playwright logo'>
    # ```
    #
    # ```python sync
    # page.get_by_alt_text("Playwright logo").click()
    # ```
    def get_by_alt_text(text, exact: nil)
      wrap_impl(@impl.get_by_alt_text(unwrap_impl(text), exact: unwrap_impl(exact)))
    end

    #
    # Allows locating input elements by the text of the associated `<label>` or `aria-labelledby` element, or by the `aria-label` attribute.
    #
    # **Usage**
    #
    # For example, this method will find inputs by label "Username" and "Password" in the following DOM:
    #
    # ```html
    # <input aria-label="Username">
    # <label for="password-input">Password:</label>
    # <input id="password-input">
    # ```
    #
    # ```python sync
    # page.get_by_label("Username").fill("john")
    # page.get_by_label("Password").fill("secret")
    # ```
    def get_by_label(text, exact: nil)
      wrap_impl(@impl.get_by_label(unwrap_impl(text), exact: unwrap_impl(exact)))
    end

    #
    # Allows locating input elements by the placeholder text.
    #
    # **Usage**
    #
    # For example, consider the following DOM structure.
    #
    # ```html
    # <input type="email" placeholder="name@example.com" />
    # ```
    #
    # You can fill the input after locating it by the placeholder text:
    #
    # ```python sync
    # page.get_by_placeholder("name@example.com").fill("playwright@microsoft.com")
    # ```
    def get_by_placeholder(text, exact: nil)
      wrap_impl(@impl.get_by_placeholder(unwrap_impl(text), exact: unwrap_impl(exact)))
    end

    #
    # Allows locating elements by their [ARIA role](https://www.w3.org/TR/wai-aria-1.2/#roles), [ARIA attributes](https://www.w3.org/TR/wai-aria-1.2/#aria-attributes) and [accessible name](https://w3c.github.io/accname/#dfn-accessible-name).
    #
    # **Usage**
    #
    # Consider the following DOM structure.
    #
    # ```html
    # <h3>Sign up</h3>
    # <label>
    #   <input type="checkbox" /> Subscribe
    # </label>
    # <br/>
    # <button>Submit</button>
    # ```
    #
    # You can locate each element by it's implicit role:
    #
    # ```python sync
    # expect(page.get_by_role("heading", name="Sign up")).to_be_visible()
    #
    # page.get_by_role("checkbox", name="Subscribe").check()
    #
    # page.get_by_role("button", name=re.compile("submit", re.IGNORECASE)).click()
    # ```
    #
    # **Details**
    #
    # Role selector **does not replace** accessibility audits and conformance tests, but rather gives early feedback about the ARIA guidelines.
    #
    # Many html elements have an implicitly [defined role](https://w3c.github.io/html-aam/#html-element-role-mappings) that is recognized by the role selector. You can find all the [supported roles here](https://www.w3.org/TR/wai-aria-1.2/#role_definitions). ARIA guidelines **do not recommend** duplicating implicit roles and attributes by setting `role` and/or `aria-*` attributes to default values.
    def get_by_role(
          role,
          checked: nil,
          disabled: nil,
          exact: nil,
          expanded: nil,
          includeHidden: nil,
          level: nil,
          name: nil,
          pressed: nil,
          selected: nil)
      wrap_impl(@impl.get_by_role(unwrap_impl(role), checked: unwrap_impl(checked), disabled: unwrap_impl(disabled), exact: unwrap_impl(exact), expanded: unwrap_impl(expanded), includeHidden: unwrap_impl(includeHidden), level: unwrap_impl(level), name: unwrap_impl(name), pressed: unwrap_impl(pressed), selected: unwrap_impl(selected)))
    end

    #
    # Locate element by the test id.
    #
    # **Usage**
    #
    # Consider the following DOM structure.
    #
    # ```html
    # <button data-testid="directions">Itinéraire</button>
    # ```
    #
    # You can locate the element by it's test id:
    #
    # ```python sync
    # page.get_by_test_id("directions").click()
    # ```
    #
    # **Details**
    #
    # By default, the `data-testid` attribute is used as a test id. Use [`method: Selectors.setTestIdAttribute`] to configure a different test id attribute if necessary.
    def get_by_test_id(testId)
      wrap_impl(@impl.get_by_test_id(unwrap_impl(testId)))
    end
    alias_method :get_by_testid, :get_by_test_id

    #
    # Allows locating elements that contain given text.
    #
    # See also [`method: Locator.filter`] that allows to match by another criteria, like an accessible role, and then filter by the text content.
    #
    # **Usage**
    #
    # Consider the following DOM structure:
    #
    # ```html
    # <div>Hello <span>world</span></div>
    # <div>Hello</div>
    # ```
    #
    # You can locate by text substring, exact string, or a regular expression:
    #
    # ```python sync
    # # Matches <span>
    # page.get_by_text("world")
    #
    # # Matches first <div>
    # page.get_by_text("Hello world")
    #
    # # Matches second <div>
    # page.get_by_text("Hello", exact=True)
    #
    # # Matches both <div>s
    # page.get_by_text(re.compile("Hello"))
    #
    # # Matches second <div>
    # page.get_by_text(re.compile("^hello$", re.IGNORECASE))
    # ```
    #
    # **Details**
    #
    # Matching by text always normalizes whitespace, even with exact match. For example, it turns multiple spaces into one, turns line breaks into spaces and ignores leading and trailing whitespace.
    #
    # Input elements of the type `button` and `submit` are matched by their `value` instead of the text content. For example, locating by text `"Log in"` matches `<input type=button value="Log in">`.
    def get_by_text(text, exact: nil)
      wrap_impl(@impl.get_by_text(unwrap_impl(text), exact: unwrap_impl(exact)))
    end

    #
    # Allows locating elements by their title attribute.
    #
    # **Usage**
    #
    # Consider the following DOM structure.
    #
    # ```html
    # <span title='Issues count'>25 issues</span>
    # ```
    #
    # You can check the issues count after locating it by the title text:
    #
    # ```python sync
    # expect(page.get_by_title("Issues count")).to_have_text("25 issues")
    # ```
    def get_by_title(text, exact: nil)
      wrap_impl(@impl.get_by_title(unwrap_impl(text), exact: unwrap_impl(exact)))
    end

    #
    # Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
    # last redirect.
    #
    # The method will throw an error if:
    # - there's an SSL error (e.g. in case of self-signed certificates).
    # - target URL is invalid.
    # - the `timeout` is exceeded during navigation.
    # - the remote server does not respond or is unreachable.
    # - the main resource failed to load.
    #
    # The method will not throw an error when any valid HTTP status code is returned by the remote server, including 404
    # "Not Found" and 500 "Internal Server Error".  The status code for such responses can be retrieved by calling
    # [`method: Response.status`].
    #
    # **NOTE**: The method either throws an error or returns a main resource response. The only exceptions are navigation to
    # `about:blank` or navigation to the same URL with a different hash, which would succeed and return `null`.
    #
    # **NOTE**: Headless mode doesn't support navigation to a PDF document. See the
    # [upstream issue](https://bugs.chromium.org/p/chromium/issues/detail?id=761295).
    def goto(url, referer: nil, timeout: nil, waitUntil: nil)
      wrap_impl(@impl.goto(unwrap_impl(url), referer: unwrap_impl(referer), timeout: unwrap_impl(timeout), waitUntil: unwrap_impl(waitUntil)))
    end

    #
    # This method hovers over an element matching `selector` by performing the following steps:
    # 1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
    # 1. Wait for [actionability](../actionability.md) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to hover over the center of the element, or the specified `position`.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a
    # `TimeoutError`. Passing zero timeout disables this.
    def hover(
          selector,
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          strict: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.hover(unwrap_impl(selector), force: unwrap_impl(force), modifiers: unwrap_impl(modifiers), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    #
    # Returns `element.innerHTML`.
    def inner_html(selector, strict: nil, timeout: nil)
      wrap_impl(@impl.inner_html(unwrap_impl(selector), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # Returns `element.innerText`.
    def inner_text(selector, strict: nil, timeout: nil)
      wrap_impl(@impl.inner_text(unwrap_impl(selector), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # Returns `input.value` for the selected `<input>` or `<textarea>` or `<select>` element.
    #
    # Throws for non-input elements. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), returns the value of the control.
    def input_value(selector, strict: nil, timeout: nil)
      wrap_impl(@impl.input_value(unwrap_impl(selector), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # Returns whether the element is checked. Throws if the element is not a checkbox or radio input.
    def checked?(selector, strict: nil, timeout: nil)
      wrap_impl(@impl.checked?(unwrap_impl(selector), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # Returns `true` if the frame has been detached, or `false` otherwise.
    def detached?
      wrap_impl(@impl.detached?)
    end

    #
    # Returns whether the element is disabled, the opposite of [enabled](../actionability.md#enabled).
    def disabled?(selector, strict: nil, timeout: nil)
      wrap_impl(@impl.disabled?(unwrap_impl(selector), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # Returns whether the element is [editable](../actionability.md#editable).
    def editable?(selector, strict: nil, timeout: nil)
      wrap_impl(@impl.editable?(unwrap_impl(selector), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # Returns whether the element is [enabled](../actionability.md#enabled).
    def enabled?(selector, strict: nil, timeout: nil)
      wrap_impl(@impl.enabled?(unwrap_impl(selector), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # Returns whether the element is hidden, the opposite of [visible](../actionability.md#visible).  `selector` that does not match any elements is considered hidden.
    def hidden?(selector, strict: nil, timeout: nil)
      wrap_impl(@impl.hidden?(unwrap_impl(selector), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # Returns whether the element is [visible](../actionability.md#visible). `selector` that does not match any elements is considered not visible.
    def visible?(selector, strict: nil, timeout: nil)
      wrap_impl(@impl.visible?(unwrap_impl(selector), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # The method returns an element locator that can be used to perform actions on this page / frame.
    # Locator is resolved to the element immediately before performing an action, so a series of actions on the same locator can in fact be performed on different DOM elements. That would happen if the DOM structure between those actions has changed.
    #
    # [Learn more about locators](../locators.md).
    #
    # [Learn more about locators](../locators.md).
    def locator(
          selector,
          has: nil,
          hasNot: nil,
          hasNotText: nil,
          hasText: nil)
      wrap_impl(@impl.locator(unwrap_impl(selector), has: unwrap_impl(has), hasNot: unwrap_impl(hasNot), hasNotText: unwrap_impl(hasNotText), hasText: unwrap_impl(hasText)))
    end

    #
    # Returns frame's name attribute as specified in the tag.
    #
    # If the name is empty, returns the id attribute instead.
    #
    # **NOTE**: This value is calculated once when the frame is created, and will not update if the attribute is changed later.
    def name
      wrap_impl(@impl.name)
    end

    #
    # Returns the page containing this frame.
    def page
      wrap_impl(@impl.page)
    end

    #
    # Parent frame, if any. Detached frames and main frames return `null`.
    def parent_frame
      wrap_impl(@impl.parent_frame)
    end

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
    # `ControlOrMeta` resolves to `Control` on Windows and Linux and to `Meta` on macOS.
    #
    # Holding down `Shift` will type the text that corresponds to the `key` in the upper case.
    #
    # If `key` is a single character, it is case-sensitive, so the values `a` and `A` will generate different
    # respective texts.
    #
    # Shortcuts such as `key: "Control+o"`, `key: "Control++` or `key: "Control+Shift+T"` are supported as well. When specified with the
    # modifier, modifier is pressed and being held while the subsequent key is being pressed.
    def press(
          selector,
          key,
          delay: nil,
          noWaitAfter: nil,
          strict: nil,
          timeout: nil)
      wrap_impl(@impl.press(unwrap_impl(selector), unwrap_impl(key), delay: unwrap_impl(delay), noWaitAfter: unwrap_impl(noWaitAfter), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # Returns the ElementHandle pointing to the frame element.
    #
    # **NOTE**: The use of `ElementHandle` is discouraged, use `Locator` objects and web-first assertions instead.
    #
    # The method finds an element matching the specified selector within the frame. If no elements match the selector,
    # returns `null`.
    def query_selector(selector, strict: nil)
      wrap_impl(@impl.query_selector(unwrap_impl(selector), strict: unwrap_impl(strict)))
    end

    #
    # Returns the ElementHandles pointing to the frame elements.
    #
    # **NOTE**: The use of `ElementHandle` is discouraged, use `Locator` objects instead.
    #
    # The method finds all elements matching the specified selector within the frame. If no elements match the selector,
    # returns empty array.
    def query_selector_all(selector)
      wrap_impl(@impl.query_selector_all(unwrap_impl(selector)))
    end

    #
    # This method waits for an element matching `selector`, waits for [actionability](../actionability.md) checks, waits until all specified options are present in the `<select>` element and selects these options.
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
    # frame.select_option("select#colors", "blue")
    # # single selection matching both the label
    # frame.select_option("select#colors", label="blue")
    # # multiple selection
    # frame.select_option("select#colors", value=["red", "green", "blue"])
    # ```
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
      wrap_impl(@impl.select_option(unwrap_impl(selector), element: unwrap_impl(element), index: unwrap_impl(index), value: unwrap_impl(value), label: unwrap_impl(label), force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # This method checks or unchecks an element matching `selector` by performing the following steps:
    # 1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
    # 1. Ensure that matched element is a checkbox or a radio input. If not, this method throws.
    # 1. If the element already has the right checked state, this method returns immediately.
    # 1. Wait for [actionability](../actionability.md) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to click in the center of the element.
    # 1. Ensure that the element is now checked or unchecked. If not, this method throws.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a
    # `TimeoutError`. Passing zero timeout disables this.
    def set_checked(
          selector,
          checked,
          force: nil,
          noWaitAfter: nil,
          position: nil,
          strict: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.set_checked(unwrap_impl(selector), unwrap_impl(checked), force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    #
    # This method internally calls [document.write()](https://developer.mozilla.org/en-US/docs/Web/API/Document/write), inheriting all its specific characteristics and behaviors.
    def set_content(html, timeout: nil, waitUntil: nil)
      wrap_impl(@impl.set_content(unwrap_impl(html), timeout: unwrap_impl(timeout), waitUntil: unwrap_impl(waitUntil)))
    end
    alias_method :content=, :set_content

    #
    # Sets the value of the file input to these file paths or files. If some of the `filePaths` are relative paths, then they
    # are resolved relative to the current working directory. For empty array, clears the selected files.
    #
    # This method expects `selector` to point to an
    # [input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input). However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), targets the control instead.
    def set_input_files(
          selector,
          files,
          noWaitAfter: nil,
          strict: nil,
          timeout: nil)
      wrap_impl(@impl.set_input_files(unwrap_impl(selector), unwrap_impl(files), noWaitAfter: unwrap_impl(noWaitAfter), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # This method taps an element matching `selector` by performing the following steps:
    # 1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
    # 1. Wait for [actionability](../actionability.md) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.touchscreen`] to tap the center of the element, or the specified `position`.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a
    # `TimeoutError`. Passing zero timeout disables this.
    #
    # **NOTE**: `frame.tap()` requires that the `hasTouch` option of the browser context be set to true.
    def tap_point(
          selector,
          force: nil,
          modifiers: nil,
          noWaitAfter: nil,
          position: nil,
          strict: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.tap_point(unwrap_impl(selector), force: unwrap_impl(force), modifiers: unwrap_impl(modifiers), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    #
    # Returns `element.textContent`.
    def text_content(selector, strict: nil, timeout: nil)
      wrap_impl(@impl.text_content(unwrap_impl(selector), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # Returns the page title.
    def title
      wrap_impl(@impl.title)
    end

    #
    # Sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text. `frame.type` can be used to
    # send fine-grained keyboard events. To fill values in form fields, use [`method: Frame.fill`].
    #
    # To press a special key, like `Control` or `ArrowDown`, use [`method: Keyboard.press`].
    #
    # **Usage**
    #
    # @deprecated In most cases, you should use [`method: Locator.fill`] instead. You only need to press keys one by one if there is special keyboard handling on the page - in this case use [`method: Locator.pressSequentially`].
    def type(
          selector,
          text,
          delay: nil,
          noWaitAfter: nil,
          strict: nil,
          timeout: nil)
      wrap_impl(@impl.type(unwrap_impl(selector), unwrap_impl(text), delay: unwrap_impl(delay), noWaitAfter: unwrap_impl(noWaitAfter), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # This method checks an element matching `selector` by performing the following steps:
    # 1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
    # 1. Ensure that matched element is a checkbox or a radio input. If not, this method throws. If the element is already unchecked, this method returns immediately.
    # 1. Wait for [actionability](../actionability.md) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to click in the center of the element.
    # 1. Ensure that the element is now unchecked. If not, this method throws.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a
    # `TimeoutError`. Passing zero timeout disables this.
    def uncheck(
          selector,
          force: nil,
          noWaitAfter: nil,
          position: nil,
          strict: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.uncheck(unwrap_impl(selector), force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    #
    # Returns frame's url.
    def url
      wrap_impl(@impl.url)
    end

    #
    # Returns when the `expression` returns a truthy value, returns that value.
    #
    # **Usage**
    #
    # The [`method: Frame.waitForFunction`] can be used to observe viewport size change:
    #
    # ```python sync
    # from playwright.sync_api import sync_playwright, Playwright
    #
    # def run(playwright: Playwright):
    #     webkit = playwright.webkit
    #     browser = webkit.launch()
    #     page = browser.new_page()
    #     page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    #     page.main_frame.wait_for_function("() => window.x > 0")
    #     browser.close()
    #
    # with sync_playwright() as playwright:
    #     run(playwright)
    # ```
    #
    # To pass an argument to the predicate of `frame.waitForFunction` function:
    #
    # ```python sync
    # selector = ".foo"
    # frame.wait_for_function("selector => !!document.querySelector(selector)", selector)
    # ```
    def wait_for_function(expression, arg: nil, polling: nil, timeout: nil)
      wrap_impl(@impl.wait_for_function(unwrap_impl(expression), arg: unwrap_impl(arg), polling: unwrap_impl(polling), timeout: unwrap_impl(timeout)))
    end

    #
    # Waits for the required load state to be reached.
    #
    # This returns when the frame reaches a required load state, `load` by default. The navigation must have been committed
    # when this method is called. If current document has already reached the required state, resolves immediately.
    #
    # **NOTE**: Most of the time, this method is not needed because Playwright [auto-waits before every action](../actionability.md).
    #
    # **Usage**
    #
    # ```python sync
    # frame.click("button") # click triggers navigation.
    # frame.wait_for_load_state() # the promise resolves after "load" event.
    # ```
    def wait_for_load_state(state: nil, timeout: nil)
      wrap_impl(@impl.wait_for_load_state(state: unwrap_impl(state), timeout: unwrap_impl(timeout)))
    end

    #
    # Waits for the frame navigation and returns the main resource response. In case of multiple redirects, the navigation
    # will resolve with the response of the last redirect. In case of navigation to a different anchor or navigation due to
    # History API usage, the navigation will resolve with `null`.
    #
    # **Usage**
    #
    # This method waits for the frame to navigate to a new URL. It is useful for when you run code which will indirectly cause
    # the frame to navigate. Consider this example:
    #
    # ```python sync
    # with frame.expect_navigation():
    #     frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
    # # Resolves after navigation has finished
    # ```
    #
    # **NOTE**: Usage of the [History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API) to change the URL is considered
    # a navigation.
    #
    # @deprecated This method is inherently racy, please use [`method: Frame.waitForURL`] instead.
    def expect_navigation(timeout: nil, url: nil, waitUntil: nil, &block)
      wrap_impl(@impl.expect_navigation(timeout: unwrap_impl(timeout), url: unwrap_impl(url), waitUntil: unwrap_impl(waitUntil), &wrap_block_call(block)))
    end

    #
    # Returns when element specified by selector satisfies `state` option. Returns `null` if waiting for `hidden` or
    # `detached`.
    #
    # **NOTE**: Playwright automatically waits for element to be ready before performing an action. Using
    # `Locator` objects and web-first assertions make the code wait-for-selector-free.
    #
    # Wait for the `selector` to satisfy `state` option (either appear/disappear from dom, or become
    # visible/hidden). If at the moment of calling the method `selector` already satisfies the condition, the method
    # will return immediately. If the selector doesn't satisfy the condition for the `timeout` milliseconds, the
    # function will throw.
    #
    # **Usage**
    #
    # This method works across navigations:
    #
    # ```python sync
    # from playwright.sync_api import sync_playwright, Playwright
    #
    # def run(playwright: Playwright):
    #     chromium = playwright.chromium
    #     browser = chromium.launch()
    #     page = browser.new_page()
    #     for current_url in ["https://google.com", "https://bbc.com"]:
    #         page.goto(current_url, wait_until="domcontentloaded")
    #         element = page.main_frame.wait_for_selector("img")
    #         print("Loaded image: " + str(element.get_attribute("src")))
    #     browser.close()
    #
    # with sync_playwright() as playwright:
    #     run(playwright)
    # ```
    def wait_for_selector(selector, state: nil, strict: nil, timeout: nil)
      wrap_impl(@impl.wait_for_selector(unwrap_impl(selector), state: unwrap_impl(state), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # Waits for the given `timeout` in milliseconds.
    #
    # Note that `frame.waitForTimeout()` should only be used for debugging. Tests using the timer in production are going to
    # be flaky. Use signals such as network events, selectors becoming visible and others instead.
    def wait_for_timeout(timeout)
      wrap_impl(@impl.wait_for_timeout(unwrap_impl(timeout)))
    end

    #
    # Waits for the frame to navigate to the given URL.
    #
    # **Usage**
    #
    # ```python sync
    # frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
    # frame.wait_for_url("**/target.html")
    # ```
    def wait_for_url(url, timeout: nil, waitUntil: nil)
      wrap_impl(@impl.wait_for_url(unwrap_impl(url), timeout: unwrap_impl(timeout), waitUntil: unwrap_impl(waitUntil)))
    end

    # @nodoc
    def highlight(selector)
      wrap_impl(@impl.highlight(unwrap_impl(selector)))
    end

    # @nodoc
    def expect(selector, expression, options, title)
      wrap_impl(@impl.expect(unwrap_impl(selector), unwrap_impl(expression), unwrap_impl(options), unwrap_impl(title)))
    end

    # @nodoc
    def detached=(req)
      wrap_impl(@impl.detached=(unwrap_impl(req)))
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
