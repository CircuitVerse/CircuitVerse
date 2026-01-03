module Playwright
  #
  # Page provides methods to interact with a single tab in a `Browser`, or an
  # [extension background page](https://developer.chrome.com/extensions/background_pages) in Chromium. One `Browser`
  # instance might have multiple `Page` instances.
  #
  # This example creates a page, navigates it to a URL, and then saves a screenshot:
  #
  # ```python sync
  # from playwright.sync_api import sync_playwright, Playwright
  #
  # def run(playwright: Playwright):
  #     webkit = playwright.webkit
  #     browser = webkit.launch()
  #     context = browser.new_context()
  #     page = context.new_page()
  #     page.goto("https://example.com")
  #     page.screenshot(path="screenshot.png")
  #     browser.close()
  #
  # with sync_playwright() as playwright:
  #     run(playwright)
  # ```
  #
  # The Page class emits various events (described below) which can be handled using any of Node's native
  # [`EventEmitter`](https://nodejs.org/api/events.html#events_class_eventemitter) methods, such as `on`, `once` or
  # `removeListener`.
  #
  # This example logs a message for a single page `load` event:
  #
  # ```py
  # page.once("load", lambda: print("page loaded!"))
  # ```
  #
  # To unsubscribe from events use the `removeListener` method:
  #
  # ```py
  # def log_request(intercepted_request):
  #     print("a request was made:", intercepted_request.url)
  # page.on("request", log_request)
  # # sometime later...
  # page.remove_listener("request", log_request)
  # ```
  class Page < PlaywrightApi

    #
    # Playwright has ability to mock clock and passage of time.
    def clock # property
      wrap_impl(@impl.clock)
    end

    def accessibility # property
      wrap_impl(@impl.accessibility)
    end

    def keyboard # property
      wrap_impl(@impl.keyboard)
    end

    def mouse # property
      wrap_impl(@impl.mouse)
    end

    #
    # API testing helper associated with this page. This method returns the same instance as
    # [`property: BrowserContext.request`] on the page's context. See [`property: BrowserContext.request`] for more details.
    def request # property
      wrap_impl(@impl.request)
    end

    def touchscreen # property
      wrap_impl(@impl.touchscreen)
    end

    #
    # Adds a script which would be evaluated in one of the following scenarios:
    # - Whenever the page is navigated.
    # - Whenever the child frame is attached or navigated. In this case, the script is evaluated in the context of the newly attached frame.
    #
    # The script is evaluated after the document was created but before any of its scripts were run. This is useful to amend
    # the JavaScript environment, e.g. to seed `Math.random`.
    #
    # **Usage**
    #
    # An example of overriding `Math.random` before the page loads:
    #
    # ```python sync
    # # in your playwright script, assuming the preload.js file is in same directory
    # page.add_init_script(path="./preload.js")
    # ```
    #
    # **NOTE**: The order of evaluation of multiple scripts installed via [`method: BrowserContext.addInitScript`] and
    # [`method: Page.addInitScript`] is not defined.
    def add_init_script(path: nil, script: nil)
      wrap_impl(@impl.add_init_script(path: unwrap_impl(path), script: unwrap_impl(script)))
    end

    #
    # Adds a `<script>` tag into the page with the desired url or content. Returns the added tag when the script's onload
    # fires or when the script content was injected into frame.
    def add_script_tag(content: nil, path: nil, type: nil, url: nil)
      wrap_impl(@impl.add_script_tag(content: unwrap_impl(content), path: unwrap_impl(path), type: unwrap_impl(type), url: unwrap_impl(url)))
    end

    #
    # Adds a `<link rel="stylesheet">` tag into the page with the desired url or a `<style type="text/css">` tag with the
    # content. Returns the added tag when the stylesheet's onload fires or when the CSS content was injected into frame.
    def add_style_tag(content: nil, path: nil, url: nil)
      wrap_impl(@impl.add_style_tag(content: unwrap_impl(content), path: unwrap_impl(path), url: unwrap_impl(url)))
    end

    #
    # Brings page to front (activates tab).
    def bring_to_front
      wrap_impl(@impl.bring_to_front)
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
    # If `runBeforeUnload` is `false`, does not run any unload handlers and waits for the page to be closed. If
    # `runBeforeUnload` is `true` the method will run unload handlers, but will **not** wait for the page to close.
    #
    # By default, `page.close()` **does not** run `beforeunload` handlers.
    #
    # **NOTE**: if `runBeforeUnload` is passed as true, a `beforeunload` dialog might be summoned and should be handled
    # manually via [`event: Page.dialog`] event.
    def close(reason: nil, runBeforeUnload: nil)
      wrap_impl(@impl.close(reason: unwrap_impl(reason), runBeforeUnload: unwrap_impl(runBeforeUnload)))
    end

    #
    # Gets the full HTML contents of the page, including the doctype.
    def content
      wrap_impl(@impl.content)
    end

    #
    # Get the browser context that the page belongs to.
    def context
      wrap_impl(@impl.context)
    end

    #
    # This method double clicks an element matching `selector` by performing the following steps:
    # 1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
    # 1. Wait for [actionability](../actionability.md) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
    # 1. Scroll the element into view if needed.
    # 1. Use [`property: Page.mouse`] to double click in the center of the element, or the specified `position`.
    #
    # When all steps combined have not finished during the specified `timeout`, this method throws a
    # `TimeoutError`. Passing zero timeout disables this.
    #
    # **NOTE**: `page.dblclick()` dispatches two `click` events and a single `dblclick` event.
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
    # page.dispatch_event("button#submit", "click")
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
    # page.dispatch_event("#source", "dragstart", { "dataTransfer": data_transfer })
    # ```
    def dispatch_event(
          selector,
          type,
          eventInit: nil,
          strict: nil,
          timeout: nil)
      wrap_impl(@impl.dispatch_event(unwrap_impl(selector), unwrap_impl(type), eventInit: unwrap_impl(eventInit), strict: unwrap_impl(strict), timeout: unwrap_impl(timeout)))
    end

    #
    # This method drags the source element to the target element.
    # It will first move to the source element, perform a `mousedown`,
    # then move to the target element and perform a `mouseup`.
    #
    # **Usage**
    #
    # ```python sync
    # page.drag_and_drop("#source", "#target")
    # # or specify exact positions relative to the top-left corners of the elements:
    # page.drag_and_drop(
    #   "#source",
    #   "#target",
    #   source_position={"x": 34, "y": 7},
    #   target_position={"x": 10, "y": 20}
    # )
    # ```
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
    # This method changes the `CSS media type` through the `media` argument, and/or the `'prefers-colors-scheme'` media feature, using the `colorScheme` argument.
    #
    # **Usage**
    #
    # ```python sync
    # page.evaluate("matchMedia('screen').matches")
    # # → True
    # page.evaluate("matchMedia('print').matches")
    # # → False
    #
    # page.emulate_media(media="print")
    # page.evaluate("matchMedia('screen').matches")
    # # → False
    # page.evaluate("matchMedia('print').matches")
    # # → True
    #
    # page.emulate_media()
    # page.evaluate("matchMedia('screen').matches")
    # # → True
    # page.evaluate("matchMedia('print').matches")
    # # → False
    # ```
    #
    # ```python sync
    # page.emulate_media(color_scheme="dark")
    # page.evaluate("matchMedia('(prefers-color-scheme: dark)').matches")
    # # → True
    # page.evaluate("matchMedia('(prefers-color-scheme: light)').matches")
    # # → False
    # ```
    def emulate_media(
          colorScheme: nil,
          contrast: nil,
          forcedColors: nil,
          media: nil,
          reducedMotion: nil)
      wrap_impl(@impl.emulate_media(colorScheme: unwrap_impl(colorScheme), contrast: unwrap_impl(contrast), forcedColors: unwrap_impl(forcedColors), media: unwrap_impl(media), reducedMotion: unwrap_impl(reducedMotion)))
    end

    #
    # The method finds an element matching the specified selector within the page and passes it as a first argument to
    # `expression`. If no elements match the selector, the method throws an error. Returns the value of
    # `expression`.
    #
    # If `expression` returns a [Promise], then [`method: Page.evalOnSelector`] would wait for the promise to resolve and
    # return its value.
    #
    # **Usage**
    #
    # ```python sync
    # search_value = page.eval_on_selector("#search", "el => el.value")
    # preload_href = page.eval_on_selector("link[rel=preload]", "el => el.href")
    # html = page.eval_on_selector(".main-container", "(e, suffix) => e.outer_html + suffix", "hello")
    # ```
    def eval_on_selector(selector, expression, arg: nil, strict: nil)
      wrap_impl(@impl.eval_on_selector(unwrap_impl(selector), unwrap_impl(expression), arg: unwrap_impl(arg), strict: unwrap_impl(strict)))
    end

    #
    # The method finds all elements matching the specified selector within the page and passes an array of matched elements as
    # a first argument to `expression`. Returns the result of `expression` invocation.
    #
    # If `expression` returns a [Promise], then [`method: Page.evalOnSelectorAll`] would wait for the promise to resolve and
    # return its value.
    #
    # **Usage**
    #
    # ```python sync
    # div_counts = page.eval_on_selector_all("div", "(divs, min) => divs.length >= min", 10)
    # ```
    def eval_on_selector_all(selector, expression, arg: nil)
      wrap_impl(@impl.eval_on_selector_all(unwrap_impl(selector), unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    #
    # Returns the value of the `expression` invocation.
    #
    # If the function passed to the [`method: Page.evaluate`] returns a [Promise], then [`method: Page.evaluate`] would wait
    # for the promise to resolve and return its value.
    #
    # If the function passed to the [`method: Page.evaluate`] returns a non-[Serializable] value, then
    # [`method: Page.evaluate`] resolves to `undefined`. Playwright also supports transferring some
    # additional values that are not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`.
    #
    # **Usage**
    #
    # Passing argument to `expression`:
    #
    # ```python sync
    # result = page.evaluate("([x, y]) => Promise.resolve(x * y)", [7, 8])
    # print(result) # prints "56"
    # ```
    #
    # A string can also be passed in instead of a function:
    #
    # ```python sync
    # print(page.evaluate("1 + 2")) # prints "3"
    # x = 10
    # print(page.evaluate(f"1 + {x}")) # prints "11"
    # ```
    #
    # `ElementHandle` instances can be passed as an argument to the [`method: Page.evaluate`]:
    #
    # ```python sync
    # body_handle = page.evaluate("document.body")
    # html = page.evaluate("([body, suffix]) => body.innerHTML + suffix", [body_handle, "hello"])
    # body_handle.dispose()
    # ```
    def evaluate(expression, arg: nil)
      wrap_impl(@impl.evaluate(unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    #
    # Returns the value of the `expression` invocation as a `JSHandle`.
    #
    # The only difference between [`method: Page.evaluate`] and [`method: Page.evaluateHandle`] is that [`method: Page.evaluateHandle`] returns `JSHandle`.
    #
    # If the function passed to the [`method: Page.evaluateHandle`] returns a [Promise], then [`method: Page.evaluateHandle`] would wait for the
    # promise to resolve and return its value.
    #
    # **Usage**
    #
    # ```python sync
    # a_window_handle = page.evaluate_handle("Promise.resolve(window)")
    # a_window_handle # handle for the window object.
    # ```
    #
    # A string can also be passed in instead of a function:
    #
    # ```python sync
    # a_handle = page.evaluate_handle("document") # handle for the "document"
    # ```
    #
    # `JSHandle` instances can be passed as an argument to the [`method: Page.evaluateHandle`]:
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
    # The method adds a function called `name` on the `window` object of every frame in this page. When called, the
    # function executes `callback` and returns a [Promise] which resolves to the return value of `callback`.
    # If the `callback` returns a [Promise], it will be awaited.
    #
    # The first argument of the `callback` function contains information about the caller: `{ browserContext:
    # BrowserContext, page: Page, frame: Frame }`.
    #
    # See [`method: BrowserContext.exposeBinding`] for the context-wide version.
    #
    # **NOTE**: Functions installed via [`method: Page.exposeBinding`] survive navigations.
    #
    # **Usage**
    #
    # An example of exposing page URL to all frames in a page:
    #
    # ```python sync
    # from playwright.sync_api import sync_playwright, Playwright
    #
    # def run(playwright: Playwright):
    #     webkit = playwright.webkit
    #     browser = webkit.launch(headless=False)
    #     context = browser.new_context()
    #     page = context.new_page()
    #     page.expose_binding("pageURL", lambda source: source["page"].url)
    #     page.set_content("""
    #     <script>
    #       async function onClick() {
    #         document.querySelector('div').textContent = await window.pageURL();
    #       }
    #     </script>
    #     <button onclick="onClick()">Click me</button>
    #     <div></div>
    #     """)
    #     page.click("button")
    #
    # with sync_playwright() as playwright:
    #     run(playwright)
    # ```
    def expose_binding(name, callback, handle: nil)
      wrap_impl(@impl.expose_binding(unwrap_impl(name), unwrap_impl(callback), handle: unwrap_impl(handle)))
    end

    #
    # The method adds a function called `name` on the `window` object of every frame in the page. When called, the
    # function executes `callback` and returns a [Promise] which resolves to the return value of `callback`.
    #
    # If the `callback` returns a [Promise], it will be awaited.
    #
    # See [`method: BrowserContext.exposeFunction`] for context-wide exposed function.
    #
    # **NOTE**: Functions installed via [`method: Page.exposeFunction`] survive navigations.
    #
    # **Usage**
    #
    # An example of adding a `sha256` function to the page:
    #
    # ```python sync
    # import hashlib
    # from playwright.sync_api import sync_playwright, Playwright
    #
    # def sha256(text):
    #     m = hashlib.sha256()
    #     m.update(bytes(text, "utf8"))
    #     return m.hexdigest()
    #
    #
    # def run(playwright: Playwright):
    #     webkit = playwright.webkit
    #     browser = webkit.launch(headless=False)
    #     page = browser.new_page()
    #     page.expose_function("sha256", sha256)
    #     page.set_content("""
    #         <script>
    #           async function onClick() {
    #             document.querySelector('div').textContent = await window.sha256('PLAYWRIGHT');
    #           }
    #         </script>
    #         <button onclick="onClick()">Click me</button>
    #         <div></div>
    #     """)
    #     page.click("button")
    #
    # with sync_playwright() as playwright:
    #     run(playwright)
    # ```
    def expose_function(name, callback)
      wrap_impl(@impl.expose_function(unwrap_impl(name), unwrap_impl(callback)))
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
    # Returns frame matching the specified criteria. Either `name` or `url` must be specified.
    #
    # **Usage**
    #
    # ```py
    # frame = page.frame(name="frame-name")
    # ```
    #
    # ```py
    # frame = page.frame(url=r".*domain.*")
    # ```
    def frame(name: nil, url: nil)
      wrap_impl(@impl.frame(name: unwrap_impl(name), url: unwrap_impl(url)))
    end

    #
    # When working with iframes, you can create a frame locator that will enter the iframe and allow selecting elements
    # in that iframe.
    #
    # **Usage**
    #
    # Following snippet locates element with text "Submit" in the iframe with id `my-frame`,
    # like `<iframe id="my-frame">`:
    #
    # ```python sync
    # locator = page.frame_locator("#my-iframe").get_by_text("Submit")
    # locator.click()
    # ```
    def frame_locator(selector)
      wrap_impl(@impl.frame_locator(unwrap_impl(selector)))
    end

    #
    # An array of all frames attached to the page.
    def frames
      wrap_impl(@impl.frames)
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
    # last redirect. If cannot go back, returns `null`.
    #
    # Navigate to the previous page in history.
    def go_back(timeout: nil, waitUntil: nil)
      wrap_impl(@impl.go_back(timeout: unwrap_impl(timeout), waitUntil: unwrap_impl(waitUntil)))
    end

    #
    # Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
    # last redirect. If cannot go forward, returns `null`.
    #
    # Navigate to the next page in history.
    def go_forward(timeout: nil, waitUntil: nil)
      wrap_impl(@impl.go_forward(timeout: unwrap_impl(timeout), waitUntil: unwrap_impl(waitUntil)))
    end

    #
    # Request the page to perform garbage collection. Note that there is no guarantee that all unreachable objects will be collected.
    #
    # This is useful to help detect memory leaks. For example, if your page has a large object `'suspect'` that might be leaked, you can check that it does not leak by using a [`WeakRef`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakRef).
    #
    # ```python sync
    # # 1. In your page, save a WeakRef for the "suspect".
    # page.evaluate("globalThis.suspectWeakRef = new WeakRef(suspect)")
    # # 2. Request garbage collection.
    # page.request_gc()
    # # 3. Check that weak ref does not deref to the original object.
    # assert page.evaluate("!globalThis.suspectWeakRef.deref()")
    # ```
    def request_gc
      raise NotImplementedError.new('request_gc is not implemented yet.')
    end

    #
    # Returns the main resource response. In case of multiple redirects, the navigation will resolve with the first
    # non-redirect response.
    #
    # The method will throw an error if:
    # - there's an SSL error (e.g. in case of self-signed certificates).
    # - target URL is invalid.
    # - the `timeout` is exceeded during navigation.
    # - the remote server does not respond or is unreachable.
    # - the main resource failed to load.
    #
    # The method will not throw an error when any valid HTTP status code is returned by the remote server, including 404 "Not
    # Found" and 500 "Internal Server Error".  The status code for such responses can be retrieved by calling
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
    # Indicates that the page has been closed.
    def closed?
      wrap_impl(@impl.closed?)
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
    def locator(
          selector,
          has: nil,
          hasNot: nil,
          hasNotText: nil,
          hasText: nil)
      wrap_impl(@impl.locator(unwrap_impl(selector), has: unwrap_impl(has), hasNot: unwrap_impl(hasNot), hasNotText: unwrap_impl(hasNotText), hasText: unwrap_impl(hasText)))
    end

    #
    # The page's main frame. Page is guaranteed to have a main frame which persists during navigations.
    def main_frame
      wrap_impl(@impl.main_frame)
    end

    #
    # Returns the opener for popup pages and `null` for others. If the opener has been closed already the returns `null`.
    def opener
      wrap_impl(@impl.opener)
    end

    #
    # Pauses script execution. Playwright will stop executing the script and wait for the user to either press the 'Resume'
    # button in the page overlay or to call `playwright.resume()` in the DevTools console.
    #
    # User can inspect selectors or perform manual steps while paused. Resume will continue running the original script from
    # the place it was paused.
    #
    # **NOTE**: This method requires Playwright to be started in a headed mode, with a falsy `headless` option.
    def pause
      wrap_impl(@impl.pause)
    end

    #
    # Returns the PDF buffer.
    #
    # `page.pdf()` generates a pdf of the page with `print` css media. To generate a pdf with `screen` media, call
    # [`method: Page.emulateMedia`] before calling `page.pdf()`:
    #
    # **NOTE**: By default, `page.pdf()` generates a pdf with modified colors for printing. Use the
    # [`-webkit-print-color-adjust`](https://developer.mozilla.org/en-US/docs/Web/CSS/-webkit-print-color-adjust) property to
    # force rendering of exact colors.
    #
    # **Usage**
    #
    # ```python sync
    # # generates a pdf with "screen" media type.
    # page.emulate_media(media="screen")
    # page.pdf(path="page.pdf")
    # ```
    #
    # The `width`, `height`, and `margin` options accept values labeled with units. Unlabeled
    # values are treated as pixels.
    #
    # A few examples:
    # - `page.pdf({width: 100})` - prints with width set to 100 pixels
    # - `page.pdf({width: '100px'})` - prints with width set to 100 pixels
    # - `page.pdf({width: '10cm'})` - prints with width set to 10 centimeters.
    #
    # All possible units are:
    # - `px` - pixel
    # - `in` - inch
    # - `cm` - centimeter
    # - `mm` - millimeter
    #
    # The `format` options are:
    # - `Letter`: 8.5in x 11in
    # - `Legal`: 8.5in x 14in
    # - `Tabloid`: 11in x 17in
    # - `Ledger`: 17in x 11in
    # - `A0`: 33.1in x 46.8in
    # - `A1`: 23.4in x 33.1in
    # - `A2`: 16.54in x 23.4in
    # - `A3`: 11.7in x 16.54in
    # - `A4`: 8.27in x 11.7in
    # - `A5`: 5.83in x 8.27in
    # - `A6`: 4.13in x 5.83in
    #
    # **NOTE**: `headerTemplate` and `footerTemplate` markup have the following limitations: > 1. Script tags inside
    # templates are not evaluated. > 2. Page styles are not visible inside templates.
    def pdf(
          displayHeaderFooter: nil,
          footerTemplate: nil,
          format: nil,
          headerTemplate: nil,
          height: nil,
          landscape: nil,
          margin: nil,
          outline: nil,
          pageRanges: nil,
          path: nil,
          preferCSSPageSize: nil,
          printBackground: nil,
          scale: nil,
          tagged: nil,
          width: nil)
      wrap_impl(@impl.pdf(displayHeaderFooter: unwrap_impl(displayHeaderFooter), footerTemplate: unwrap_impl(footerTemplate), format: unwrap_impl(format), headerTemplate: unwrap_impl(headerTemplate), height: unwrap_impl(height), landscape: unwrap_impl(landscape), margin: unwrap_impl(margin), outline: unwrap_impl(outline), pageRanges: unwrap_impl(pageRanges), path: unwrap_impl(path), preferCSSPageSize: unwrap_impl(preferCSSPageSize), printBackground: unwrap_impl(printBackground), scale: unwrap_impl(scale), tagged: unwrap_impl(tagged), width: unwrap_impl(width)))
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
    # `ControlOrMeta` resolves to `Control` on Windows and Linux and to `Meta` on macOS.
    #
    # Holding down `Shift` will type the text that corresponds to the `key` in the upper case.
    #
    # If `key` is a single character, it is case-sensitive, so the values `a` and `A` will generate different
    # respective texts.
    #
    # Shortcuts such as `key: "Control+o"`, `key: "Control++` or `key: "Control+Shift+T"` are supported as well. When specified with the
    # modifier, modifier is pressed and being held while the subsequent key is being pressed.
    #
    # **Usage**
    #
    # ```python sync
    # page = browser.new_page()
    # page.goto("https://keycode.info")
    # page.press("body", "A")
    # page.screenshot(path="a.png")
    # page.press("body", "ArrowLeft")
    # page.screenshot(path="arrow_left.png")
    # page.press("body", "Shift+O")
    # page.screenshot(path="o.png")
    # browser.close()
    # ```
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
    # The method finds an element matching the specified selector within the page. If no elements match the selector, the
    # return value resolves to `null`. To wait for an element on the page, use [`method: Locator.waitFor`].
    def query_selector(selector, strict: nil)
      wrap_impl(@impl.query_selector(unwrap_impl(selector), strict: unwrap_impl(strict)))
    end

    #
    # The method finds all elements matching the specified selector within the page. If no elements match the selector, the
    # return value resolves to `[]`.
    def query_selector_all(selector)
      wrap_impl(@impl.query_selector_all(unwrap_impl(selector)))
    end

    #
    # When testing a web page, sometimes unexpected overlays like a "Sign up" dialog appear and block actions you want to automate, e.g. clicking a button. These overlays don't always show up in the same way or at the same time, making them tricky to handle in automated tests.
    #
    # This method lets you set up a special function, called a handler, that activates when it detects that overlay is visible. The handler's job is to remove the overlay, allowing your test to continue as if the overlay wasn't there.
    #
    # Things to keep in mind:
    # - When an overlay is shown predictably, we recommend explicitly waiting for it in your test and dismissing it as a part of your normal test flow, instead of using [`method: Page.addLocatorHandler`].
    # - Playwright checks for the overlay every time before executing or retrying an action that requires an [actionability check](../actionability.md), or before performing an auto-waiting assertion check. When overlay is visible, Playwright calls the handler first, and then proceeds with the action/assertion. Note that the handler is only called when you perform an action/assertion - if the overlay becomes visible but you don't perform any actions, the handler will not be triggered.
    # - After executing the handler, Playwright will ensure that overlay that triggered the handler is not visible anymore. You can opt-out of this behavior with `noWaitAfter`.
    # - The execution time of the handler counts towards the timeout of the action/assertion that executed the handler. If your handler takes too long, it might cause timeouts.
    # - You can register multiple handlers. However, only a single handler will be running at a time. Make sure the actions within a handler don't depend on another handler.
    #
    # **NOTE**: Running the handler will alter your page state mid-test. For example it will change the currently focused element and move the mouse. Make sure that actions that run after the handler are self-contained and do not rely on the focus and mouse state being unchanged.
    #
    # For example, consider a test that calls [`method: Locator.focus`] followed by [`method: Keyboard.press`]. If your handler clicks a button between these two actions, the focused element most likely will be wrong, and key press will happen on the unexpected element. Use [`method: Locator.press`] instead to avoid this problem.
    #
    # Another example is a series of mouse actions, where [`method: Mouse.move`] is followed by [`method: Mouse.down`]. Again, when the handler runs between these two actions, the mouse position will be wrong during the mouse down. Prefer self-contained actions like [`method: Locator.click`] that do not rely on the state being unchanged by a handler.
    #
    # **Usage**
    #
    # An example that closes a "Sign up to the newsletter" dialog when it appears:
    #
    # ```python sync
    # # Setup the handler.
    # def handler():
    #   page.get_by_role("button", name="No thanks").click()
    # page.add_locator_handler(page.get_by_text("Sign up to the newsletter"), handler)
    #
    # # Write the test as usual.
    # page.goto("https://example.com")
    # page.get_by_role("button", name="Start here").click()
    # ```
    #
    # An example that skips the "Confirm your security details" page when it is shown:
    #
    # ```python sync
    # # Setup the handler.
    # def handler():
    #   page.get_by_role("button", name="Remind me later").click()
    # page.add_locator_handler(page.get_by_text("Confirm your security details"), handler)
    #
    # # Write the test as usual.
    # page.goto("https://example.com")
    # page.get_by_role("button", name="Start here").click()
    # ```
    #
    # An example with a custom callback on every actionability check. It uses a `<body>` locator that is always visible, so the handler is called before every actionability check. It is important to specify `noWaitAfter`, because the handler does not hide the `<body>` element.
    #
    # ```python sync
    # # Setup the handler.
    # def handler():
    #   page.evaluate("window.removeObstructionsForTestIfNeeded()")
    # page.add_locator_handler(page.locator("body"), handler, no_wait_after=True)
    #
    # # Write the test as usual.
    # page.goto("https://example.com")
    # page.get_by_role("button", name="Start here").click()
    # ```
    #
    # Handler takes the original locator as an argument. You can also automatically remove the handler after a number of invocations by setting `times`:
    #
    # ```python sync
    # def handler(locator):
    #   locator.click()
    # page.add_locator_handler(page.get_by_label("Close"), handler, times=1)
    # ```
    def add_locator_handler(locator, handler, noWaitAfter: nil, times: nil)
      raise NotImplementedError.new('add_locator_handler is not implemented yet.')
    end

    #
    # Removes all locator handlers added by [`method: Page.addLocatorHandler`] for a specific locator.
    def remove_locator_handler(locator)
      raise NotImplementedError.new('remove_locator_handler is not implemented yet.')
    end

    #
    # This method reloads the current page, in the same way as if the user had triggered a browser refresh.
    # Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
    # last redirect.
    def reload(timeout: nil, waitUntil: nil)
      wrap_impl(@impl.reload(timeout: unwrap_impl(timeout), waitUntil: unwrap_impl(waitUntil)))
    end

    #
    # Routing provides the capability to modify network requests that are made by a page.
    #
    # Once routing is enabled, every request matching the url pattern will stall unless it's continued, fulfilled or aborted.
    #
    # **NOTE**: The handler will only be called for the first url if the response is a redirect.
    #
    # **NOTE**: [`method: Page.route`] will not intercept requests intercepted by Service Worker. See [this](https://github.com/microsoft/playwright/issues/1090) issue. We recommend disabling Service Workers when using request interception by setting `serviceWorkers` to `'block'`.
    #
    # **NOTE**: [`method: Page.route`] will not intercept the first request of a popup page. Use [`method: BrowserContext.route`] instead.
    #
    # **Usage**
    #
    # An example of a naive handler that aborts all image requests:
    #
    # ```python sync
    # page = browser.new_page()
    # page.route("**/*.{png,jpg,jpeg}", lambda route: route.abort())
    # page.goto("https://example.com")
    # browser.close()
    # ```
    #
    # or the same snippet using a regex pattern instead:
    #
    # ```python sync
    # page = browser.new_page()
    # page.route(re.compile(r"(\.png$)|(\.jpg$)"), lambda route: route.abort())
    # page.goto("https://example.com")
    # browser.close()
    # ```
    #
    # It is possible to examine the request to decide the route action. For example, mocking all requests that contain some post data, and leaving all other requests as is:
    #
    # ```python sync
    # def handle_route(route: Route):
    #   if ("my-string" in route.request.post_data):
    #     route.fulfill(body="mocked-data")
    #   else:
    #     route.continue_()
    # page.route("/api/**", handle_route)
    # ```
    #
    # Page routes take precedence over browser context routes (set up with [`method: BrowserContext.route`]) when request
    # matches both handlers.
    #
    # To remove a route with its handler you can use [`method: Page.unroute`].
    #
    # **NOTE**: Enabling routing disables http cache.
    def route(url, handler, times: nil)
      wrap_impl(@impl.route(unwrap_impl(url), unwrap_impl(handler), times: unwrap_impl(times)))
    end

    #
    # If specified the network requests that are made in the page will be served from the HAR file. Read more about [Replaying from HAR](../mock.md#replaying-from-har).
    #
    # Playwright will not serve requests intercepted by Service Worker from the HAR file. See [this](https://github.com/microsoft/playwright/issues/1090) issue. We recommend disabling Service Workers when using request interception by setting `serviceWorkers` to `'block'`.
    def route_from_har(
          har,
          notFound: nil,
          update: nil,
          updateContent: nil,
          updateMode: nil,
          url: nil)
      wrap_impl(@impl.route_from_har(unwrap_impl(har), notFound: unwrap_impl(notFound), update: unwrap_impl(update), updateContent: unwrap_impl(updateContent), updateMode: unwrap_impl(updateMode), url: unwrap_impl(url)))
    end

    #
    # This method allows to modify websocket connections that are made by the page.
    #
    # Note that only `WebSocket`s created after this method was called will be routed. It is recommended to call this method before navigating the page.
    #
    # **Usage**
    #
    # Below is an example of a simple mock that responds to a single message. See `WebSocketRoute` for more details and examples.
    #
    # ```python sync
    # def message_handler(ws: WebSocketRoute, message: Union[str, bytes]):
    #   if message == "request":
    #     ws.send("response")
    #
    # def handler(ws: WebSocketRoute):
    #   ws.on_message(lambda message: message_handler(ws, message))
    #
    # page.route_web_socket("/ws", handler)
    # ```
    def route_web_socket(url, handler)
      raise NotImplementedError.new('route_web_socket is not implemented yet.')
    end

    #
    # Returns the buffer with the captured screenshot.
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
      wrap_impl(@impl.screenshot(animations: unwrap_impl(animations), caret: unwrap_impl(caret), clip: unwrap_impl(clip), fullPage: unwrap_impl(fullPage), mask: unwrap_impl(mask), maskColor: unwrap_impl(maskColor), omitBackground: unwrap_impl(omitBackground), path: unwrap_impl(path), quality: unwrap_impl(quality), scale: unwrap_impl(scale), style: unwrap_impl(style), timeout: unwrap_impl(timeout), type: unwrap_impl(type)))
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
    # page.select_option("select#colors", "blue")
    # # single selection matching both the label
    # page.select_option("select#colors", label="blue")
    # # multiple selection
    # page.select_option("select#colors", value=["red", "green", "blue"])
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
    # This setting will change the default maximum navigation time for the following methods and related shortcuts:
    # - [`method: Page.goBack`]
    # - [`method: Page.goForward`]
    # - [`method: Page.goto`]
    # - [`method: Page.reload`]
    # - [`method: Page.setContent`]
    # - [`method: Page.waitForNavigation`]
    # - [`method: Page.waitForURL`]
    #
    # **NOTE**: [`method: Page.setDefaultNavigationTimeout`] takes priority over [`method: Page.setDefaultTimeout`],
    # [`method: BrowserContext.setDefaultTimeout`] and [`method: BrowserContext.setDefaultNavigationTimeout`].
    def set_default_navigation_timeout(timeout)
      wrap_impl(@impl.set_default_navigation_timeout(unwrap_impl(timeout)))
    end
    alias_method :default_navigation_timeout=, :set_default_navigation_timeout

    #
    # This setting will change the default maximum time for all the methods accepting `timeout` option.
    #
    # **NOTE**: [`method: Page.setDefaultNavigationTimeout`] takes priority over [`method: Page.setDefaultTimeout`].
    def set_default_timeout(timeout)
      wrap_impl(@impl.set_default_timeout(unwrap_impl(timeout)))
    end
    alias_method :default_timeout=, :set_default_timeout

    #
    # The extra HTTP headers will be sent with every request the page initiates.
    #
    # **NOTE**: [`method: Page.setExtraHTTPHeaders`] does not guarantee the order of headers in the outgoing requests.
    def set_extra_http_headers(headers)
      wrap_impl(@impl.set_extra_http_headers(unwrap_impl(headers)))
    end
    alias_method :extra_http_headers=, :set_extra_http_headers

    #
    # Sets the value of the file input to these file paths or files. If some of the `filePaths` are relative paths, then they
    # are resolved relative to the current working directory. For empty array, clears the selected files.
    # For inputs with a `[webkitdirectory]` attribute, only a single directory path is supported.
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
    # In the case of multiple pages in a single browser, each page can have its own viewport size. However,
    # [`method: Browser.newContext`] allows to set viewport size (and more) for all pages in the context at once.
    #
    # [`method: Page.setViewportSize`] will resize the page. A lot of websites don't expect phones to change size, so you should set the
    # viewport size before navigating to the page. [`method: Page.setViewportSize`] will also reset `screen` size, use [`method: Browser.newContext`] with `screen` and `viewport` parameters if you need better control of these properties.
    #
    # **Usage**
    #
    # ```python sync
    # page = browser.new_page()
    # page.set_viewport_size({"width": 640, "height": 480})
    # page.goto("https://example.com")
    # ```
    def set_viewport_size(viewportSize)
      wrap_impl(@impl.set_viewport_size(unwrap_impl(viewportSize)))
    end
    alias_method :viewport_size=, :set_viewport_size

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
    # **NOTE**: [`method: Page.tap`] the method will throw if `hasTouch` option of the browser context is false.
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
    # Returns the page's title.
    def title
      wrap_impl(@impl.title)
    end

    #
    # Sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text. `page.type` can be used to send
    # fine-grained keyboard events. To fill values in form fields, use [`method: Page.fill`].
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
    # This method unchecks an element matching `selector` by performing the following steps:
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
    # Removes all routes created with [`method: Page.route`] and [`method: Page.routeFromHAR`].
    def unroute_all(behavior: nil)
      wrap_impl(@impl.unroute_all(behavior: unwrap_impl(behavior)))
    end

    #
    # Removes a route created with [`method: Page.route`]. When `handler` is not specified, removes all routes for
    # the `url`.
    def unroute(url, handler: nil)
      wrap_impl(@impl.unroute(unwrap_impl(url), handler: unwrap_impl(handler)))
    end

    def url
      wrap_impl(@impl.url)
    end

    #
    # Video object associated with this page.
    def video
      wrap_impl(@impl.video)
    end

    def viewport_size
      wrap_impl(@impl.viewport_size)
    end

    #
    # Performs action and waits for a `ConsoleMessage` to be logged by in the page. If predicate is provided, it passes
    # `ConsoleMessage` value into the `predicate` function and waits for `predicate(message)` to return a truthy value.
    # Will throw an error if the page is closed before the [`event: Page.console`] event is fired.
    def expect_console_message(predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_console_message(predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    #
    # Performs action and waits for a new `Download`. If predicate is provided, it passes
    # `Download` value into the `predicate` function and waits for `predicate(download)` to return a truthy value.
    # Will throw an error if the page is closed before the download event is fired.
    def expect_download(predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_download(predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    #
    # Waits for event to fire and passes its value into the predicate function. Returns when the predicate returns truthy
    # value. Will throw an error if the page is closed before the event is fired. Returns the event data value.
    #
    # **Usage**
    #
    # ```python sync
    # with page.expect_event("framenavigated") as event_info:
    #     page.get_by_role("button")
    # frame = event_info.value
    # ```
    def expect_event(event, predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_event(unwrap_impl(event), predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    #
    # Performs action and waits for a new `FileChooser` to be created. If predicate is provided, it passes
    # `FileChooser` value into the `predicate` function and waits for `predicate(fileChooser)` to return a truthy value.
    # Will throw an error if the page is closed before the file chooser is opened.
    def expect_file_chooser(predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_file_chooser(predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    #
    # Returns when the `expression` returns a truthy value. It resolves to a JSHandle of the truthy value.
    #
    # **Usage**
    #
    # The [`method: Page.waitForFunction`] can be used to observe viewport size change:
    #
    # ```python sync
    # from playwright.sync_api import sync_playwright, Playwright
    #
    # def run(playwright: Playwright):
    #     webkit = playwright.webkit
    #     browser = webkit.launch()
    #     page = browser.new_page()
    #     page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
    #     page.wait_for_function("() => window.x > 0")
    #     browser.close()
    #
    # with sync_playwright() as playwright:
    #     run(playwright)
    # ```
    #
    # To pass an argument to the predicate of [`method: Page.waitForFunction`] function:
    #
    # ```python sync
    # selector = ".foo"
    # page.wait_for_function("selector => !!document.querySelector(selector)", selector)
    # ```
    def wait_for_function(expression, arg: nil, polling: nil, timeout: nil)
      wrap_impl(@impl.wait_for_function(unwrap_impl(expression), arg: unwrap_impl(arg), polling: unwrap_impl(polling), timeout: unwrap_impl(timeout)))
    end

    #
    # Returns when the required load state has been reached.
    #
    # This resolves when the page reaches a required load state, `load` by default. The navigation must have been committed
    # when this method is called. If current document has already reached the required state, resolves immediately.
    #
    # **NOTE**: Most of the time, this method is not needed because Playwright [auto-waits before every action](../actionability.md).
    #
    # **Usage**
    #
    # ```python sync
    # page.get_by_role("button").click() # click triggers navigation.
    # page.wait_for_load_state() # the promise resolves after "load" event.
    # ```
    #
    # ```python sync
    # with page.expect_popup() as page_info:
    #     page.get_by_role("button").click() # click triggers a popup.
    # popup = page_info.value
    # # Wait for the "DOMContentLoaded" event.
    # popup.wait_for_load_state("domcontentloaded")
    # print(popup.title()) # popup is ready to use.
    # ```
    def wait_for_load_state(state: nil, timeout: nil)
      wrap_impl(@impl.wait_for_load_state(state: unwrap_impl(state), timeout: unwrap_impl(timeout)))
    end

    #
    # Waits for the main frame navigation and returns the main resource response. In case of multiple redirects, the navigation
    # will resolve with the response of the last redirect. In case of navigation to a different anchor or navigation due to
    # History API usage, the navigation will resolve with `null`.
    #
    # **Usage**
    #
    # This resolves when the page navigates to a new URL or reloads. It is useful for when you run code which will indirectly
    # cause the page to navigate. e.g. The click target has an `onclick` handler that triggers navigation from a `setTimeout`.
    # Consider this example:
    #
    # ```python sync
    # with page.expect_navigation():
    #     # This action triggers the navigation after a timeout.
    #     page.get_by_text("Navigate after timeout").click()
    # # Resolves after navigation has finished
    # ```
    #
    # **NOTE**: Usage of the [History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API) to change the URL is considered
    # a navigation.
    #
    # @deprecated This method is inherently racy, please use [`method: Page.waitForURL`] instead.
    def expect_navigation(timeout: nil, url: nil, waitUntil: nil, &block)
      wrap_impl(@impl.expect_navigation(timeout: unwrap_impl(timeout), url: unwrap_impl(url), waitUntil: unwrap_impl(waitUntil), &wrap_block_call(block)))
    end

    #
    # Performs action and waits for a popup `Page`. If predicate is provided, it passes
    # [Popup] value into the `predicate` function and waits for `predicate(page)` to return a truthy value.
    # Will throw an error if the page is closed before the popup event is fired.
    def expect_popup(predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_popup(predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    #
    # Waits for the matching request and returns it. See [waiting for event](../events.md#waiting-for-event) for more details about events.
    #
    # **Usage**
    #
    # ```python sync
    # with page.expect_request("http://example.com/resource") as first:
    #     page.get_by_text("trigger request").click()
    # first_request = first.value
    #
    # # or with a lambda
    # with page.expect_request(lambda request: request.url == "http://example.com" and request.method == "get") as second:
    #     page.get_by_text("trigger request").click()
    # second_request = second.value
    # ```
    def expect_request(urlOrPredicate, timeout: nil, &block)
      wrap_impl(@impl.expect_request(unwrap_impl(urlOrPredicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    #
    # Performs action and waits for a `Request` to finish loading. If predicate is provided, it passes
    # `Request` value into the `predicate` function and waits for `predicate(request)` to return a truthy value.
    # Will throw an error if the page is closed before the [`event: Page.requestFinished`] event is fired.
    def expect_request_finished(predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_request_finished(predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    #
    # Returns the matched response. See [waiting for event](../events.md#waiting-for-event) for more details about events.
    #
    # **Usage**
    #
    # ```python sync
    # with page.expect_response("https://example.com/resource") as response_info:
    #     page.get_by_text("trigger response").click()
    # response = response_info.value
    # return response.ok
    #
    # # or with a lambda
    # with page.expect_response(lambda response: response.url == "https://example.com" and response.status == 200 and response.request.method == "get") as response_info:
    #     page.get_by_text("trigger response").click()
    # response = response_info.value
    # return response.ok
    # ```
    def expect_response(urlOrPredicate, timeout: nil, &block)
      wrap_impl(@impl.expect_response(unwrap_impl(urlOrPredicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    #
    # Returns when element specified by selector satisfies `state` option. Returns `null` if waiting for `hidden` or
    # `detached`.
    #
    # **NOTE**: Playwright automatically waits for element to be ready before performing an action. Using
    # `Locator` objects and web-first assertions makes the code wait-for-selector-free.
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
    #         element = page.wait_for_selector("img")
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
    # Note that `page.waitForTimeout()` should only be used for debugging. Tests using the timer in production are going to be
    # flaky. Use signals such as network events, selectors becoming visible and others instead.
    #
    # **Usage**
    #
    # ```python sync
    # # wait for 1 second
    # page.wait_for_timeout(1000)
    # ```
    def wait_for_timeout(timeout)
      wrap_impl(@impl.wait_for_timeout(unwrap_impl(timeout)))
    end

    #
    # Waits for the main frame to navigate to the given URL.
    #
    # **Usage**
    #
    # ```python sync
    # page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
    # page.wait_for_url("**/target.html")
    # ```
    def wait_for_url(url, timeout: nil, waitUntil: nil)
      wrap_impl(@impl.wait_for_url(unwrap_impl(url), timeout: unwrap_impl(timeout), waitUntil: unwrap_impl(waitUntil)))
    end

    #
    # Performs action and waits for a new `WebSocket`. If predicate is provided, it passes
    # `WebSocket` value into the `predicate` function and waits for `predicate(webSocket)` to return a truthy value.
    # Will throw an error if the page is closed before the WebSocket event is fired.
    def expect_websocket(predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_websocket(predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    #
    # Performs action and waits for a new `Worker`. If predicate is provided, it passes
    # `Worker` value into the `predicate` function and waits for `predicate(worker)` to return a truthy value.
    # Will throw an error if the page is closed before the worker event is fired.
    def expect_worker(predicate: nil, timeout: nil, &block)
      wrap_impl(@impl.expect_worker(predicate: unwrap_impl(predicate), timeout: unwrap_impl(timeout), &wrap_block_call(block)))
    end

    #
    # This method returns all of the dedicated [WebWorkers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API)
    # associated with the page.
    #
    # **NOTE**: This does not contain ServiceWorkers
    def workers
      wrap_impl(@impl.workers)
    end

    #
    # **NOTE**: In most cases, you should use [`method: Page.waitForEvent`].
    #
    # Waits for given `event` to fire. If predicate is provided, it passes
    # event's value into the `predicate` function and waits for `predicate(event)` to return a truthy value.
    # Will throw an error if the page is closed before the `event` is fired.
    def wait_for_event(event, predicate: nil, timeout: nil)
      raise NotImplementedError.new('wait_for_event is not implemented yet.')
    end

    # @nodoc
    def guid
      wrap_impl(@impl.guid)
    end

    # @nodoc
    def snapshot_for_ai(timeout: nil)
      wrap_impl(@impl.snapshot_for_ai(timeout: unwrap_impl(timeout)))
    end

    # @nodoc
    def start_js_coverage(resetOnNavigation: nil, reportAnonymousScripts: nil)
      wrap_impl(@impl.start_js_coverage(resetOnNavigation: unwrap_impl(resetOnNavigation), reportAnonymousScripts: unwrap_impl(reportAnonymousScripts)))
    end

    # @nodoc
    def stop_js_coverage
      wrap_impl(@impl.stop_js_coverage)
    end

    # @nodoc
    def start_css_coverage(resetOnNavigation: nil, reportAnonymousScripts: nil)
      wrap_impl(@impl.start_css_coverage(resetOnNavigation: unwrap_impl(resetOnNavigation), reportAnonymousScripts: unwrap_impl(reportAnonymousScripts)))
    end

    # @nodoc
    def stop_css_coverage
      wrap_impl(@impl.stop_css_coverage)
    end

    # @nodoc
    def owned_context=(req)
      wrap_impl(@impl.owned_context=(unwrap_impl(req)))
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
