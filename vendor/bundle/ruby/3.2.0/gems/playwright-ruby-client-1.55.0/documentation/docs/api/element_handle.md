---
sidebar_position: 10
---

# ElementHandle

- extends: [JSHandle](./js_handle)

ElementHandle represents an in-page DOM element. ElementHandles can be created with the [Page#query_selector](./page#query_selector) method.

**NOTE**: The use of ElementHandle is discouraged, use [Locator](./locator) objects and web-first assertions instead.

```ruby
href_element = page.query_selector("a")
href_element.click
```

ElementHandle prevents DOM element from garbage collection unless the handle is disposed with
[JSHandle#dispose](./js_handle#dispose). ElementHandles are auto-disposed when their origin frame gets navigated.

ElementHandle instances can be used as an argument in [Page#eval_on_selector](./page#eval_on_selector) and [Page#evaluate](./page#evaluate) methods.

The difference between the [Locator](./locator) and ElementHandle is that the ElementHandle points to a particular element, while [Locator](./locator) captures the logic of how to retrieve an element.

In the example below, handle points to a particular DOM element on page. If that element changes text or is used by React to render an entirely different component, handle is still pointing to that very DOM element. This can lead to unexpected behaviors.

```ruby
handle = page.query_selector("text=Submit")
handle.hover
handle.click
```

With the locator, every time the `element` is used, up-to-date DOM element is located in the page using the selector. So in the snippet below, underlying DOM element is going to be located twice.

```ruby
locator = page.get_by_text("Submit")
locator.hover
locator.click
```

## bounding_box

```
def bounding_box
```


This method returns the bounding box of the element, or `null` if the element is not visible. The bounding box is
calculated relative to the main frame viewport - which is usually the same as the browser window.

Scrolling affects the returned bounding box, similarly to
[Element.getBoundingClientRect](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect). That
means `x` and/or `y` may be negative.

Elements from child frames return the bounding box relative to the main frame, unlike the
[Element.getBoundingClientRect](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect).

Assuming the page is static, it is safe to use bounding box coordinates to perform input. For example, the following
snippet should click the center of the element.

**Usage**

```ruby
box = element_handle.bounding_box
page.mouse.click(
  box["x"] + box["width"] / 2,
  box["y"] + box["height"] / 2,
)
```

## check

```
def check(
      force: nil,
      noWaitAfter: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```


This method checks the element by performing the following steps:
1. Ensure that element is a checkbox or a radio input. If not, this method throws. If the element is already checked, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Ensure that the element is now checked. If not, this method throws.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

## click

```
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
```


This method clicks the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

## content_frame

```
def content_frame
```


Returns the content frame for element handles referencing iframe nodes, or `null` otherwise

## dblclick

```
def dblclick(
      button: nil,
      delay: nil,
      force: nil,
      modifiers: nil,
      noWaitAfter: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```


This method double clicks the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to double click in the center of the element, or the specified `position`.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

**NOTE**: `elementHandle.dblclick()` dispatches two `click` events and a single `dblclick` event.

## dispatch_event

```
def dispatch_event(type, eventInit: nil)
```


The snippet below dispatches the `click` event on the element. Regardless of the visibility state of the element, `click`
is dispatched. This is equivalent to calling
[element.click()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/click).

**Usage**

```ruby
element_handle.dispatch_event("click")
```

Under the hood, it creates an instance of an event based on the given `type`, initializes it with
`eventInit` properties and dispatches it on the element. Events are `composed`, `cancelable` and bubble by
default.

Since `eventInit` is event-specific, please refer to the events documentation for the lists of initial
properties:
- [DeviceMotionEvent](https://developer.mozilla.org/en-US/docs/Web/API/DeviceMotionEvent/DeviceMotionEvent)
- [DeviceOrientationEvent](https://developer.mozilla.org/en-US/docs/Web/API/DeviceOrientationEvent/DeviceOrientationEvent)
- [DragEvent](https://developer.mozilla.org/en-US/docs/Web/API/DragEvent/DragEvent)
- [Event](https://developer.mozilla.org/en-US/docs/Web/API/Event/Event)
- [FocusEvent](https://developer.mozilla.org/en-US/docs/Web/API/FocusEvent/FocusEvent)
- [KeyboardEvent](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/KeyboardEvent)
- [MouseEvent](https://developer.mozilla.org/en-US/docs/Web/API/MouseEvent/MouseEvent)
- [PointerEvent](https://developer.mozilla.org/en-US/docs/Web/API/PointerEvent/PointerEvent)
- [TouchEvent](https://developer.mozilla.org/en-US/docs/Web/API/TouchEvent/TouchEvent)
- [WheelEvent](https://developer.mozilla.org/en-US/docs/Web/API/WheelEvent/WheelEvent)

You can also specify [JSHandle](./js_handle) as the property value if you want live objects to be passed into the event:

```ruby
data_transfer = page.evaluate_handle("new DataTransfer()")
element_handle.dispatch_event("dragstart", eventInit: { dataTransfer: data_transfer })
```

## eval_on_selector

```
def eval_on_selector(selector, expression, arg: nil)
```


Returns the return value of `expression`.

The method finds an element matching the specified selector in the [ElementHandle](./element_handle)s subtree and passes it as a first
argument to `expression`. If no elements match the selector, the method throws an error.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [ElementHandle#eval_on_selector](./element_handle#eval_on_selector) would wait for the promise to resolve and return its
value.

**Usage**

```ruby
tweet_handle = page.query_selector(".tweet")
tweet_handle.eval_on_selector(".like", "node => node.innerText") # => "100"
tweet_handle.eval_on_selector(".retweets", "node => node.innerText") # => "10"
```

## eval_on_selector_all

```
def eval_on_selector_all(selector, expression, arg: nil)
```


Returns the return value of `expression`.

The method finds all elements matching the specified selector in the [ElementHandle](./element_handle)'s subtree and passes an array of
matched elements as a first argument to `expression`.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [ElementHandle#eval_on_selector_all](./element_handle#eval_on_selector_all) would wait for the promise to resolve and return its
value.

**Usage**

```html
<div class="feed">
  <div class="tweet">Hello!</div>
  <div class="tweet">Hi!</div>
</div>
```

```ruby
feed_handle = page.query_selector(".feed")
feed_handle.eval_on_selector_all(".tweet", "nodes => nodes.map(n => n.innerText)") # => ["hello!", "hi!"]
```

## fill

```
def fill(value, force: nil, noWaitAfter: nil, timeout: nil)
```


This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, focuses the element, fills it and triggers an `input` event after filling. Note that you can pass an empty string to clear the input field.

If the target element is not an `<input>`, `<textarea>` or `[contenteditable]` element, this method throws an error. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be filled instead.

To send fine-grained keyboard events, use [Locator#press_sequentially](./locator#press_sequentially).

## focus

```
def focus
```


Calls [focus](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/focus) on the element.

## get_attribute

```
def get_attribute(name)
```
alias: `[]`


Returns element attribute value.

## hover

```
def hover(
      force: nil,
      modifiers: nil,
      noWaitAfter: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```


This method hovers over the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to hover over the center of the element, or the specified `position`.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

## inner_html

```
def inner_html
```


Returns the `element.innerHTML`.

## inner_text

```
def inner_text
```


Returns the `element.innerText`.

## input_value

```
def input_value(timeout: nil)
```


Returns `input.value` for the selected `<input>` or `<textarea>` or `<select>` element.

Throws for non-input elements. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), returns the value of the control.

## checked?

```
def checked?
```


Returns whether the element is checked. Throws if the element is not a checkbox or radio input.

## disabled?

```
def disabled?
```


Returns whether the element is disabled, the opposite of [enabled](https://playwright.dev/python/docs/actionability#enabled).

## editable?

```
def editable?
```


Returns whether the element is [editable](https://playwright.dev/python/docs/actionability#editable).

## enabled?

```
def enabled?
```


Returns whether the element is [enabled](https://playwright.dev/python/docs/actionability#enabled).

## hidden?

```
def hidden?
```


Returns whether the element is hidden, the opposite of [visible](https://playwright.dev/python/docs/actionability#visible).

## visible?

```
def visible?
```


Returns whether the element is [visible](https://playwright.dev/python/docs/actionability#visible).

## owner_frame

```
def owner_frame
```


Returns the frame containing the given element.

## press

```
def press(key, delay: nil, noWaitAfter: nil, timeout: nil)
```


Focuses the element, and then uses [Keyboard#down](./keyboard#down) and [Keyboard#up](./keyboard#up).

`key` can specify the intended
[keyboardEvent.key](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key) value or a single character to
generate the text for. A superset of the `key` values can be found
[here](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values). Examples of the keys are:

`F1` - `F12`, `Digit0`- `Digit9`, `KeyA`- `KeyZ`, `Backquote`, `Minus`, `Equal`, `Backslash`, `Backspace`, `Tab`,
`Delete`, `Escape`, `ArrowDown`, `End`, `Enter`, `Home`, `Insert`, `PageDown`, `PageUp`, `ArrowRight`, `ArrowUp`, etc.

Following modification shortcuts are also supported: `Shift`, `Control`, `Alt`, `Meta`, `ShiftLeft`, `ControlOrMeta`.

Holding down `Shift` will type the text that corresponds to the `key` in the upper case.

If `key` is a single character, it is case-sensitive, so the values `a` and `A` will generate different
respective texts.

Shortcuts such as `key: "Control+o"`, `key: "Control++` or `key: "Control+Shift+T"` are supported as well. When specified with the
modifier, modifier is pressed and being held while the subsequent key is being pressed.

## query_selector

```
def query_selector(selector)
```


The method finds an element matching the specified selector in the [ElementHandle](./element_handle)'s subtree. If no elements match the selector,
returns `null`.

## query_selector_all

```
def query_selector_all(selector)
```


The method finds all elements matching the specified selector in the [ElementHandle](./element_handle)s subtree. If no elements match the selector,
returns empty array.

## screenshot

```
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
```


This method captures a screenshot of the page, clipped to the size and position of this particular element. If the element is covered by other elements, it will not be actually visible on the screenshot. If the element is a scrollable container, only the currently scrolled content will be visible on the screenshot.

This method waits for the [actionability](https://playwright.dev/python/docs/actionability) checks, then scrolls element into view before taking a
screenshot. If the element is detached from DOM, the method throws an error.

Returns the buffer with the captured screenshot.

## scroll_into_view_if_needed

```
def scroll_into_view_if_needed(timeout: nil)
```


This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, then tries to scroll element into view, unless it is
completely visible as defined by
[IntersectionObserver](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API)'s `ratio`.

Throws when `elementHandle` does not point to an element
[connected](https://developer.mozilla.org/en-US/docs/Web/API/Node/isConnected) to a Document or a ShadowRoot.

See [scrolling](https://playwright.dev/python/docs/input#scrolling) for alternative ways to scroll.

## select_option

```
def select_option(
      element: nil,
      index: nil,
      value: nil,
      label: nil,
      force: nil,
      noWaitAfter: nil,
      timeout: nil)
```


This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, waits until all specified options are present in the `<select>` element and selects these options.

If the target element is not a `<select>` element, this method throws an error. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be used instead.

Returns the array of option values that have been successfully selected.

Triggers a `change` and `input` event once all the provided options have been selected.

**Usage**

```ruby
# single selection matching the value
element_handle.select_option(value: "blue")
# single selection matching both the label
element_handle.select_option(label: "blue")
# multiple selection
element_handle.select_option(value: ["red", "green", "blue"])
```

## select_text

```
def select_text(force: nil, timeout: nil)
```


This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, then focuses the element and selects all its text
content.

If the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), focuses and selects text in the control instead.

## set_checked

```
def set_checked(
      checked,
      force: nil,
      noWaitAfter: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```
alias: `checked=`


This method checks or unchecks an element by performing the following steps:
1. Ensure that element is a checkbox or a radio input. If not, this method throws.
1. If the element already has the right checked state, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Ensure that the element is now checked or unchecked. If not, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

## set_input_files

```
def set_input_files(files, noWaitAfter: nil, timeout: nil)
```
alias: `input_files=`


Sets the value of the file input to these file paths or files. If some of the `filePaths` are relative paths, then they
are resolved relative to the current working directory. For empty array, clears the selected files.
For inputs with a `[webkitdirectory]` attribute, only a single directory path is supported.

This method expects [ElementHandle](./element_handle) to point to an
[input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input). However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), targets the control instead.

## tap_point

```
def tap_point(
      force: nil,
      modifiers: nil,
      noWaitAfter: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```


This method taps the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#touchscreen](./page#touchscreen) to tap the center of the element, or the specified `position`.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

**NOTE**: `elementHandle.tap()` requires that the `hasTouch` option of the browser context be set to true.

## text_content

```
def text_content
```


Returns the `node.textContent`.

## type

```
def type(text, delay: nil, noWaitAfter: nil, timeout: nil)
```

:::warning

In most cases, you should use [Locator#fill](./locator#fill) instead. You only need to press keys one by one if there is special keyboard handling on the page - in this case use [Locator#press_sequentially](./locator#press_sequentially).

:::


Focuses the element, and then sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text.

To press a special key, like `Control` or `ArrowDown`, use [ElementHandle#press](./element_handle#press).

**Usage**

## uncheck

```
def uncheck(
      force: nil,
      noWaitAfter: nil,
      position: nil,
      timeout: nil,
      trial: nil)
```


This method checks the element by performing the following steps:
1. Ensure that element is a checkbox or a radio input. If not, this method throws. If the element is already unchecked, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Ensure that the element is now unchecked. If not, this method throws.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

## wait_for_element_state

```
def wait_for_element_state(state, timeout: nil)
```


Returns when the element satisfies the `state`.

Depending on the `state` parameter, this method waits for one of the [actionability](https://playwright.dev/python/docs/actionability) checks
to pass. This method throws when the element is detached while waiting, unless waiting for the `"hidden"` state.
- `"visible"` Wait until the element is [visible](https://playwright.dev/python/docs/actionability#visible).
- `"hidden"` Wait until the element is [not visible](https://playwright.dev/python/docs/actionability#visible) or not attached. Note that waiting for hidden does not throw when the element detaches.
- `"stable"` Wait until the element is both [visible](https://playwright.dev/python/docs/actionability#visible) and [stable](https://playwright.dev/python/docs/actionability#stable).
- `"enabled"` Wait until the element is [enabled](https://playwright.dev/python/docs/actionability#enabled).
- `"disabled"` Wait until the element is [not enabled](https://playwright.dev/python/docs/actionability#enabled).
- `"editable"` Wait until the element is [editable](https://playwright.dev/python/docs/actionability#editable).

If the element does not satisfy the condition for the `timeout` milliseconds, this method will throw.

## wait_for_selector

```
def wait_for_selector(selector, state: nil, strict: nil, timeout: nil)
```


Returns element specified by selector when it satisfies `state` option. Returns `null` if waiting for `hidden`
or `detached`.

Wait for the `selector` relative to the element handle to satisfy `state` option (either
appear/disappear from dom, or become visible/hidden). If at the moment of calling the method `selector` already
satisfies the condition, the method will return immediately. If the selector doesn't satisfy the condition for the
`timeout` milliseconds, the function will throw.

**Usage**

```ruby
page.content = "<div><span></span></div>"
div = page.query_selector("div")
# waiting for the "span" selector relative to the div.
span = div.wait_for_selector("span", state: "attached")
```

**NOTE**: This method does not work across navigations, use [Page#wait_for_selector](./page#wait_for_selector) instead.
