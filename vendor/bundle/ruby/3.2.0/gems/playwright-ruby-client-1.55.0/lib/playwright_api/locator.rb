module Playwright
  #
  # Locators are the central piece of Playwright's auto-waiting and retry-ability. In a nutshell, locators represent
  # a way to find element(s) on the page at any moment. A locator can be created with the [`method: Page.locator`] method.
  #
  # [Learn more about locators](../locators.md).
  class Locator < PlaywrightApi

    #
    # When the locator points to a list of elements, this returns an array of locators, pointing to their respective elements.
    #
    # **NOTE**: [`method: Locator.all`] does not wait for elements to match the locator, and instead immediately returns whatever is present in the page.
    #
    # When the list of elements changes dynamically, [`method: Locator.all`] will produce unpredictable and flaky results.
    #
    # When the list of elements is stable, but loaded dynamically, wait for the full list to finish loading before calling [`method: Locator.all`].
    #
    # **Usage**
    #
    # ```python sync
    # for li in page.get_by_role('listitem').all():
    #   li.click();
    # ```
    def all
      wrap_impl(@impl.all)
    end

    #
    # Returns an array of `node.innerText` values for all matching nodes.
    #
    # **NOTE**: If you need to assert text on the page, prefer [`method: LocatorAssertions.toHaveText`] with `useInnerText` option to avoid flakiness. See [assertions guide](../test-assertions.md) for more details.
    #
    # **Usage**
    #
    # ```python sync
    # texts = page.get_by_role("link").all_inner_texts()
    # ```
    def all_inner_texts
      wrap_impl(@impl.all_inner_texts)
    end

    #
    # Returns an array of `node.textContent` values for all matching nodes.
    #
    # **NOTE**: If you need to assert text on the page, prefer [`method: LocatorAssertions.toHaveText`] to avoid flakiness. See [assertions guide](../test-assertions.md) for more details.
    #
    # **Usage**
    #
    # ```python sync
    # texts = page.get_by_role("link").all_text_contents()
    # ```
    def all_text_contents
      wrap_impl(@impl.all_text_contents)
    end

    #
    # Creates a locator that matches both this locator and the argument locator.
    #
    # **Usage**
    #
    # The following example finds a button with a specific title.
    #
    # ```python sync
    # button = page.get_by_role("button").and_(page.getByTitle("Subscribe"))
    # ```
    def and(locator)
      wrap_impl(@impl.and(unwrap_impl(locator)))
    end

    #
    # Captures the aria snapshot of the given element.
    # Read more about [aria snapshots](../aria-snapshots.md) and [`method: LocatorAssertions.toMatchAriaSnapshot`] for the corresponding assertion.
    #
    # **Usage**
    #
    # ```python sync
    # page.get_by_role("link").aria_snapshot()
    # ```
    #
    # **Details**
    #
    # This method captures the aria snapshot of the given element. The snapshot is a string that represents the state of the element and its children.
    # The snapshot can be used to assert the state of the element in the test, or to compare it to state in the future.
    #
    # The ARIA snapshot is represented using [YAML](https://yaml.org/spec/1.2.2/) markup language:
    # - The keys of the objects are the roles and optional accessible names of the elements.
    # - The values are either text content or an array of child elements.
    # - Generic static text can be represented with the `text` key.
    #
    # Below is the HTML markup and the respective ARIA snapshot:
    #
    # ```html
    # <ul aria-label="Links">
    #   <li><a href="/">Home</a></li>
    #   <li><a href="/about">About</a></li>
    # <ul>
    # ```
    #
    # ```yml
    # - list "Links":
    #   - listitem:
    #     - link "Home"
    #   - listitem:
    #     - link "About"
    # ```
    def aria_snapshot(timeout: nil)
      wrap_impl(@impl.aria_snapshot(timeout: unwrap_impl(timeout)))
    end

    #
    # Calls [blur](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/blur) on the element.
    def blur(timeout: nil)
      wrap_impl(@impl.blur(timeout: unwrap_impl(timeout)))
    end

    #
    # This method returns the bounding box of the element matching the locator, or `null` if the element is not visible. The bounding box is
    # calculated relative to the main frame viewport - which is usually the same as the browser window.
    #
    # **Details**
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
    # box = page.get_by_role("button").bounding_box()
    # page.mouse.click(box["x"] + box["width"] / 2, box["y"] + box["height"] / 2)
    # ```
    def bounding_box(timeout: nil)
      wrap_impl(@impl.bounding_box(timeout: unwrap_impl(timeout)))
    end

    #
    # Ensure that checkbox or radio element is checked.
    #
    # **Details**
    #
    # Performs the following steps:
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
    #
    # **Usage**
    #
    # ```python sync
    # page.get_by_role("checkbox").check()
    # ```
    def check(
          force: nil,
          noWaitAfter: nil,
          position: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.check(force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), position: unwrap_impl(position), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    #
    # Clear the input field.
    #
    # **Details**
    #
    # This method waits for [actionability](../actionability.md) checks, focuses the element, clears it and triggers an `input` event after clearing.
    #
    # If the target element is not an `<input>`, `<textarea>` or `[contenteditable]` element, this method throws an error. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be cleared instead.
    #
    # **Usage**
    #
    # ```python sync
    # page.get_by_role("textbox").clear()
    # ```
    def clear(force: nil, noWaitAfter: nil, timeout: nil)
      wrap_impl(@impl.clear(force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    #
    # Click an element.
    #
    # **Details**
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
    #
    # **Usage**
    #
    # Click a button:
    #
    # ```python sync
    # page.get_by_role("button").click()
    # ```
    #
    # Shift-right-click at a specific position on a canvas:
    #
    # ```python sync
    # page.locator("canvas").click(
    #     button="right", modifiers=["Shift"], position={"x": 23, "y": 32}
    # )
    # ```
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
    # Returns the number of elements matching the locator.
    #
    # **NOTE**: If you need to assert the number of elements on the page, prefer [`method: LocatorAssertions.toHaveCount`] to avoid flakiness. See [assertions guide](../test-assertions.md) for more details.
    #
    # **Usage**
    #
    # ```python sync
    # count = page.get_by_role("listitem").count()
    # ```
    def count
      wrap_impl(@impl.count)
    end

    #
    # Double-click an element.
    #
    # **Details**
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
    # **NOTE**: `element.dblclick()` dispatches two `click` events and a single `dblclick` event.
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
    # Describes the locator, description is used in the trace viewer and reports.
    # Returns the locator pointing to the same element.
    #
    # **Usage**
    #
    # ```python sync
    # button = page.get_by_test_id("btn-sub").describe("Subscribe button")
    # button.click()
    # ```
    def describe(description)
      wrap_impl(@impl.describe(unwrap_impl(description)))
    end

    #
    # Programmatically dispatch an event on the matching element.
    #
    # **Usage**
    #
    # ```python sync
    # locator.dispatch_event("click")
    # ```
    #
    # **Details**
    #
    # The snippet above dispatches the `click` event on the element. Regardless of the visibility state of the element, `click`
    # is dispatched. This is equivalent to calling
    # [element.click()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/click).
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
    # data_transfer = page.evaluate_handle("new DataTransfer()")
    # locator.dispatch_event("#source", "dragstart", {"dataTransfer": data_transfer})
    # ```
    def dispatch_event(type, eventInit: nil, timeout: nil)
      wrap_impl(@impl.dispatch_event(unwrap_impl(type), eventInit: unwrap_impl(eventInit), timeout: unwrap_impl(timeout)))
    end

    #
    # Drag the source element towards the target element and drop it.
    #
    # **Details**
    #
    # This method drags the locator to another target locator or target position. It will
    # first move to the source element, perform a `mousedown`, then move to the target
    # element or position and perform a `mouseup`.
    #
    # **Usage**
    #
    # ```python sync
    # source = page.locator("#source")
    # target = page.locator("#target")
    #
    # source.drag_to(target)
    # # or specify exact positions relative to the top-left corners of the elements:
    # source.drag_to(
    #   target,
    #   source_position={"x": 34, "y": 7},
    #   target_position={"x": 10, "y": 20}
    # )
    # ```
    def drag_to(
          target,
          force: nil,
          noWaitAfter: nil,
          sourcePosition: nil,
          targetPosition: nil,
          timeout: nil,
          trial: nil)
      wrap_impl(@impl.drag_to(unwrap_impl(target), force: unwrap_impl(force), noWaitAfter: unwrap_impl(noWaitAfter), sourcePosition: unwrap_impl(sourcePosition), targetPosition: unwrap_impl(targetPosition), timeout: unwrap_impl(timeout), trial: unwrap_impl(trial)))
    end

    #
    # Resolves given locator to the first matching DOM element. If there are no matching elements, waits for one. If multiple elements match the locator, throws.
    def element_handle(timeout: nil)
      wrap_impl(@impl.element_handle(timeout: unwrap_impl(timeout)))
    end

    #
    # Resolves given locator to all matching DOM elements. If there are no matching elements, returns an empty list.
    def element_handles
      wrap_impl(@impl.element_handles)
    end

    #
    # Returns a `FrameLocator` object pointing to the same `iframe` as this locator.
    #
    # Useful when you have a `Locator` object obtained somewhere, and later on would like to interact with the content inside the frame.
    #
    # For a reverse operation, use [`method: FrameLocator.owner`].
    #
    # **Usage**
    #
    # ```python sync
    # locator = page.locator("iframe[name=\"embedded\"]")
    # # ...
    # frame_locator = locator.content_frame
    # frame_locator.get_by_role("button").click()
    # ```
    def content_frame
      wrap_impl(@impl.content_frame)
    end

    #
    # Execute JavaScript code in the page, taking the matching element as an argument.
    #
    # **Details**
    #
    # Returns the return value of `expression`, called with the matching element as a first argument, and `arg` as a second argument.
    #
    # If `expression` returns a [Promise], this method will wait for the promise to resolve and return its value.
    #
    # If `expression` throws or rejects, this method throws.
    #
    # **Usage**
    #
    # Passing argument to `expression`:
    #
    # ```python sync
    # result = page.get_by_testid("myId").evaluate("(element, [x, y]) => element.textContent + ' ' + x * y", [7, 8])
    # print(result) # prints "myId text 56"
    # ```
    def evaluate(expression, arg: nil, timeout: nil)
      wrap_impl(@impl.evaluate(unwrap_impl(expression), arg: unwrap_impl(arg), timeout: unwrap_impl(timeout)))
    end

    #
    # Execute JavaScript code in the page, taking all matching elements as an argument.
    #
    # **Details**
    #
    # Returns the return value of `expression`, called with an array of all matching elements as a first argument, and `arg` as a second argument.
    #
    # If `expression` returns a [Promise], this method will wait for the promise to resolve and return its value.
    #
    # If `expression` throws or rejects, this method throws.
    #
    # **Usage**
    #
    # ```python sync
    # locator = page.locator("div")
    # more_than_ten = locator.evaluate_all("(divs, min) => divs.length > min", 10)
    # ```
    def evaluate_all(expression, arg: nil)
      wrap_impl(@impl.evaluate_all(unwrap_impl(expression), arg: unwrap_impl(arg)))
    end

    #
    # Execute JavaScript code in the page, taking the matching element as an argument, and return a `JSHandle` with the result.
    #
    # **Details**
    #
    # Returns the return value of `expression` as a`JSHandle`, called with the matching element as a first argument, and `arg` as a second argument.
    #
    # The only difference between [`method: Locator.evaluate`] and [`method: Locator.evaluateHandle`] is that [`method: Locator.evaluateHandle`] returns `JSHandle`.
    #
    # If `expression` returns a [Promise], this method will wait for the promise to resolve and return its value.
    #
    # If `expression` throws or rejects, this method throws.
    #
    # See [`method: Page.evaluateHandle`] for more details.
    def evaluate_handle(expression, arg: nil, timeout: nil)
      wrap_impl(@impl.evaluate_handle(unwrap_impl(expression), arg: unwrap_impl(arg), timeout: unwrap_impl(timeout)))
    end

    #
    # Set a value to the input field.
    #
    # **Usage**
    #
    # ```python sync
    # page.get_by_role("textbox").fill("example value")
    # ```
    #
    # **Details**
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
    # This method narrows existing locator according to the options, for example filters by text.
    # It can be chained to filter multiple times.
    #
    # **Usage**
    #
    # ```python sync
    # row_locator = page.locator("tr")
    # # ...
    # row_locator.filter(has_text="text in column 1").filter(
    #     has=page.get_by_role("button", name="column 2 button")
    # ).screenshot()
    # ```
    def filter(
          has: nil,
          hasNot: nil,
          hasNotText: nil,
          hasText: nil,
          visible: nil)
      wrap_impl(@impl.filter(has: unwrap_impl(has), hasNot: unwrap_impl(hasNot), hasNotText: unwrap_impl(hasNotText), hasText: unwrap_impl(hasText), visible: unwrap_impl(visible)))
    end

    #
    # Returns locator to the first matching element.
    def first
      wrap_impl(@impl.first)
    end

    #
    # Calls [focus](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/focus) on the matching element.
    def focus(timeout: nil)
      wrap_impl(@impl.focus(timeout: unwrap_impl(timeout)))
    end

    #
    # When working with iframes, you can create a frame locator that will enter the iframe and allow locating elements
    # in that iframe:
    #
    # **Usage**
    #
    # ```python sync
    # locator = page.frame_locator("iframe").get_by_text("Submit")
    # locator.click()
    # ```
    def frame_locator(selector)
      wrap_impl(@impl.frame_locator(unwrap_impl(selector)))
    end

    #
    # Returns the matching element's attribute value.
    #
    # **NOTE**: If you need to assert an element's attribute, prefer [`method: LocatorAssertions.toHaveAttribute`] to avoid flakiness. See [assertions guide](../test-assertions.md) for more details.
    def get_attribute(name, timeout: nil)
      wrap_impl(@impl.get_attribute(unwrap_impl(name), timeout: unwrap_impl(timeout)))
    end
    alias_method :[], :get_attribute

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
    # Highlight the corresponding element(s) on the screen. Useful for debugging, don't commit the code that uses [`method: Locator.highlight`].
    def highlight
      wrap_impl(@impl.highlight)
    end

    #
    # Hover over the matching element.
    #
    # **Usage**
    #
    # ```python sync
    # page.get_by_role("link").hover()
    # ```
    #
    # **Details**
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
    # Returns the [`element.innerHTML`](https://developer.mozilla.org/en-US/docs/Web/API/Element/innerHTML).
    def inner_html(timeout: nil)
      wrap_impl(@impl.inner_html(timeout: unwrap_impl(timeout)))
    end

    #
    # Returns the [`element.innerText`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/innerText).
    #
    # **NOTE**: If you need to assert text on the page, prefer [`method: LocatorAssertions.toHaveText`] with `useInnerText` option to avoid flakiness. See [assertions guide](../test-assertions.md) for more details.
    def inner_text(timeout: nil)
      wrap_impl(@impl.inner_text(timeout: unwrap_impl(timeout)))
    end

    #
    # Returns the value for the matching `<input>` or `<textarea>` or `<select>` element.
    #
    # **NOTE**: If you need to assert input value, prefer [`method: LocatorAssertions.toHaveValue`] to avoid flakiness. See [assertions guide](../test-assertions.md) for more details.
    #
    # **Usage**
    #
    # ```python sync
    # value = page.get_by_role("textbox").input_value()
    # ```
    #
    # **Details**
    #
    # Throws elements that are not an input, textarea or a select. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), returns the value of the control.
    def input_value(timeout: nil)
      wrap_impl(@impl.input_value(timeout: unwrap_impl(timeout)))
    end

    #
    # Returns whether the element is checked. Throws if the element is not a checkbox or radio input.
    #
    # **NOTE**: If you need to assert that checkbox is checked, prefer [`method: LocatorAssertions.toBeChecked`] to avoid flakiness. See [assertions guide](../test-assertions.md) for more details.
    #
    # **Usage**
    #
    # ```python sync
    # checked = page.get_by_role("checkbox").is_checked()
    # ```
    def checked?(timeout: nil)
      wrap_impl(@impl.checked?(timeout: unwrap_impl(timeout)))
    end

    #
    # Returns whether the element is disabled, the opposite of [enabled](../actionability.md#enabled).
    #
    # **NOTE**: If you need to assert that an element is disabled, prefer [`method: LocatorAssertions.toBeDisabled`] to avoid flakiness. See [assertions guide](../test-assertions.md) for more details.
    #
    # **Usage**
    #
    # ```python sync
    # disabled = page.get_by_role("button").is_disabled()
    # ```
    def disabled?(timeout: nil)
      wrap_impl(@impl.disabled?(timeout: unwrap_impl(timeout)))
    end

    #
    # Returns whether the element is [editable](../actionability.md#editable). If the target element is not an `<input>`, `<textarea>`, `<select>`, `[contenteditable]` and does not have a role allowing `[aria-readonly]`, this method throws an error.
    #
    # **NOTE**: If you need to assert that an element is editable, prefer [`method: LocatorAssertions.toBeEditable`] to avoid flakiness. See [assertions guide](../test-assertions.md) for more details.
    #
    # **Usage**
    #
    # ```python sync
    # editable = page.get_by_role("textbox").is_editable()
    # ```
    def editable?(timeout: nil)
      wrap_impl(@impl.editable?(timeout: unwrap_impl(timeout)))
    end

    #
    # Returns whether the element is [enabled](../actionability.md#enabled).
    #
    # **NOTE**: If you need to assert that an element is enabled, prefer [`method: LocatorAssertions.toBeEnabled`] to avoid flakiness. See [assertions guide](../test-assertions.md) for more details.
    #
    # **Usage**
    #
    # ```python sync
    # enabled = page.get_by_role("button").is_enabled()
    # ```
    def enabled?(timeout: nil)
      wrap_impl(@impl.enabled?(timeout: unwrap_impl(timeout)))
    end

    #
    # Returns whether the element is hidden, the opposite of [visible](../actionability.md#visible).
    #
    # **NOTE**: If you need to assert that element is hidden, prefer [`method: LocatorAssertions.toBeHidden`] to avoid flakiness. See [assertions guide](../test-assertions.md) for more details.
    #
    # **Usage**
    #
    # ```python sync
    # hidden = page.get_by_role("button").is_hidden()
    # ```
    def hidden?(timeout: nil)
      wrap_impl(@impl.hidden?(timeout: unwrap_impl(timeout)))
    end

    #
    # Returns whether the element is [visible](../actionability.md#visible).
    #
    # **NOTE**: If you need to assert that element is visible, prefer [`method: LocatorAssertions.toBeVisible`] to avoid flakiness. See [assertions guide](../test-assertions.md) for more details.
    #
    # **Usage**
    #
    # ```python sync
    # visible = page.get_by_role("button").is_visible()
    # ```
    def visible?(timeout: nil)
      wrap_impl(@impl.visible?(timeout: unwrap_impl(timeout)))
    end

    #
    # Returns locator to the last matching element.
    #
    # **Usage**
    #
    # ```python sync
    # banana = page.get_by_role("listitem").last
    # ```
    def last
      wrap_impl(@impl.last)
    end

    #
    # The method finds an element matching the specified selector in the locator's subtree. It also accepts filter options, similar to [`method: Locator.filter`] method.
    #
    # [Learn more about locators](../locators.md).
    def locator(
          selectorOrLocator,
          has: nil,
          hasNot: nil,
          hasNotText: nil,
          hasText: nil)
      wrap_impl(@impl.locator(unwrap_impl(selectorOrLocator), has: unwrap_impl(has), hasNot: unwrap_impl(hasNot), hasNotText: unwrap_impl(hasNotText), hasText: unwrap_impl(hasText)))
    end

    #
    # Returns locator to the n-th matching element. It's zero based, `nth(0)` selects the first element.
    #
    # **Usage**
    #
    # ```python sync
    # banana = page.get_by_role("listitem").nth(2)
    # ```
    def nth(index)
      wrap_impl(@impl.nth(unwrap_impl(index)))
    end

    #
    # Creates a locator matching all elements that match one or both of the two locators.
    #
    # Note that when both locators match something, the resulting locator will have multiple matches, potentially causing a [locator strictness](../locators.md#strictness) violation.
    #
    # **Usage**
    #
    # Consider a scenario where you'd like to click on a "New email" button, but sometimes a security settings dialog shows up instead. In this case, you can wait for either a "New email" button, or a dialog and act accordingly.
    #
    # **NOTE**: If both "New email" button and security dialog appear on screen, the "or" locator will match both of them,
    # possibly throwing the ["strict mode violation" error](../locators.md#strictness). In this case, you can use [`method: Locator.first`] to only match one of them.
    #
    # ```python sync
    # new_email = page.get_by_role("button", name="New")
    # dialog = page.get_by_text("Confirm security settings")
    # expect(new_email.or_(dialog).first).to_be_visible()
    # if (dialog.is_visible()):
    #   page.get_by_role("button", name="Dismiss").click()
    # new_email.click()
    # ```
    def or(locator)
      wrap_impl(@impl.or(unwrap_impl(locator)))
    end

    #
    # A page this locator belongs to.
    def page
      wrap_impl(@impl.page)
    end

    #
    # Focuses the matching element and presses a combination of the keys.
    #
    # **Usage**
    #
    # ```python sync
    # page.get_by_role("textbox").press("Backspace")
    # ```
    #
    # **Details**
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
    def press(key, delay: nil, noWaitAfter: nil, timeout: nil)
      wrap_impl(@impl.press(unwrap_impl(key), delay: unwrap_impl(delay), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    #
    # **NOTE**: In most cases, you should use [`method: Locator.fill`] instead. You only need to press keys one by one if there is special keyboard handling on the page.
    #
    # Focuses the element, and then sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text.
    #
    # To press a special key, like `Control` or `ArrowDown`, use [`method: Locator.press`].
    #
    # **Usage**
    #
    # ```python sync
    # locator.press_sequentially("hello") # types instantly
    # locator.press_sequentially("world", delay=100) # types slower, like a user
    # ```
    #
    # An example of typing into a text field and then submitting the form:
    #
    # ```python sync
    # locator = page.get_by_label("Password")
    # locator.press_sequentially("my password")
    # locator.press("Enter")
    # ```
    def press_sequentially(text, delay: nil, noWaitAfter: nil, timeout: nil)
      wrap_impl(@impl.press_sequentially(unwrap_impl(text), delay: unwrap_impl(delay), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    #
    # Take a screenshot of the element matching the locator.
    #
    # **Usage**
    #
    # ```python sync
    # page.get_by_role("link").screenshot()
    # ```
    #
    # Disable animations and save screenshot to a file:
    #
    # ```python sync
    # page.get_by_role("link").screenshot(animations="disabled", path="link.png")
    # ```
    #
    # **Details**
    #
    # This method captures a screenshot of the page, clipped to the size and position of a particular element matching the locator. If the element is covered by other elements, it will not be actually visible on the screenshot. If the element is a scrollable container, only the currently scrolled content will be visible on the screenshot.
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
    # See [scrolling](../input.md#scrolling) for alternative ways to scroll.
    def scroll_into_view_if_needed(timeout: nil)
      wrap_impl(@impl.scroll_into_view_if_needed(timeout: unwrap_impl(timeout)))
    end

    #
    # Selects option or options in `<select>`.
    #
    # **Details**
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
    # ```html
    # <select multiple>
    #   <option value="red">Red</option>
    #   <option value="green">Green</option>
    #   <option value="blue">Blue</option>
    # </select>
    # ```
    #
    # ```python sync
    # # single selection matching the value or label
    # element.select_option("blue")
    # # single selection matching the label
    # element.select_option(label="blue")
    # # multiple selection for blue, red and second option
    # element.select_option(value=["red", "green", "blue"])
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
    # Set the state of a checkbox or a radio element.
    #
    # **Usage**
    #
    # ```python sync
    # page.get_by_role("checkbox").set_checked(True)
    # ```
    #
    # **Details**
    #
    # This method checks or unchecks an element by performing the following steps:
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
    # Upload file or multiple files into `<input type=file>`.
    # For inputs with a `[webkitdirectory]` attribute, only a single directory path is supported.
    #
    # **Usage**
    #
    # ```python sync
    # # Select one file
    # page.get_by_label("Upload file").set_input_files('myfile.pdf')
    #
    # # Select multiple files
    # page.get_by_label("Upload files").set_input_files(['file1.txt', 'file2.txt'])
    #
    # # Select a directory
    # page.get_by_label("Upload directory").set_input_files('mydir')
    #
    # # Remove all the selected files
    # page.get_by_label("Upload file").set_input_files([])
    #
    # # Upload buffer from memory
    # page.get_by_label("Upload file").set_input_files(
    #     files=[
    #         {"name": "test.txt", "mimeType": "text/plain", "buffer": b"this is a test"}
    #     ],
    # )
    # ```
    #
    # **Details**
    #
    # Sets the value of the file input to these file paths or files. If some of the `filePaths` are relative paths, then they
    # are resolved relative to the current working directory. For empty array, clears the selected files.
    #
    # This method expects `Locator` to point to an
    # [input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input). However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), targets the control instead.
    def set_input_files(files, noWaitAfter: nil, timeout: nil)
      wrap_impl(@impl.set_input_files(unwrap_impl(files), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end
    alias_method :input_files=, :set_input_files

    #
    # Perform a tap gesture on the element matching the locator. For examples of emulating other gestures by manually dispatching touch events, see the [emulating legacy touch events](../touch-events.md) page.
    #
    # **Details**
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
    # **NOTE**: `element.tap()` requires that the `hasTouch` option of the browser context be set to true.
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
    # Returns the [`node.textContent`](https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent).
    #
    # **NOTE**: If you need to assert text on the page, prefer [`method: LocatorAssertions.toHaveText`] to avoid flakiness. See [assertions guide](../test-assertions.md) for more details.
    def text_content(timeout: nil)
      wrap_impl(@impl.text_content(timeout: unwrap_impl(timeout)))
    end

    #
    # Focuses the element, and then sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text.
    #
    # To press a special key, like `Control` or `ArrowDown`, use [`method: Locator.press`].
    #
    # **Usage**
    #
    # @deprecated In most cases, you should use [`method: Locator.fill`] instead. You only need to press keys one by one if there is special keyboard handling on the page - in this case use [`method: Locator.pressSequentially`].
    def type(text, delay: nil, noWaitAfter: nil, timeout: nil)
      wrap_impl(@impl.type(unwrap_impl(text), delay: unwrap_impl(delay), noWaitAfter: unwrap_impl(noWaitAfter), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensure that checkbox or radio element is unchecked.
    #
    # **Usage**
    #
    # ```python sync
    # page.get_by_role("checkbox").uncheck()
    # ```
    #
    # **Details**
    #
    # This method unchecks the element by performing the following steps:
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
    # Returns when element specified by locator satisfies the `state` option.
    #
    # If target element already satisfies the condition, the method returns immediately. Otherwise, waits for up to
    # `timeout` milliseconds until the condition is met.
    #
    # **Usage**
    #
    # ```python sync
    # order_sent = page.locator("#order-sent")
    # order_sent.wait_for()
    # ```
    def wait_for(state: nil, timeout: nil)
      wrap_impl(@impl.wait_for(state: unwrap_impl(state), timeout: unwrap_impl(timeout)))
    end

    # @nodoc
    def expect(expression, options, title)
      wrap_impl(@impl.expect(unwrap_impl(expression), unwrap_impl(options), unwrap_impl(title)))
    end

    # @nodoc
    def resolve_selector
      wrap_impl(@impl.resolve_selector)
    end

    # @nodoc
    def to_s
      wrap_impl(@impl.to_s)
    end
  end
end
