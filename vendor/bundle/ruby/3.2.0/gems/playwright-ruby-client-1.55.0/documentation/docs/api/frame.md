---
sidebar_position: 10
---

# Frame


At every point of time, page exposes its current frame tree via the [Page#main_frame](./page#main_frame) and
[Frame#child_frames](./frame#child_frames) methods.

[Frame](./frame) object's lifecycle is controlled by three events, dispatched on the page object:
- [`event: Page.frameAttached`] - fired when the frame gets attached to the page. A Frame can be attached to the page only once.
- [`event: Page.frameNavigated`] - fired when the frame commits navigation to a different URL.
- [`event: Page.frameDetached`] - fired when the frame gets detached from the page.  A Frame can be detached from the page only once.

An example of dumping frame tree:

```ruby
def dump_frame_tree(frame, indent = 0)
  puts "#{' ' * indent}#{frame.name}@#{frame.url}"
  frame.child_frames.each do |child|
    dump_frame_tree(child, indent + 2)
  end
end

page.goto("https://www.theverge.com")
dump_frame_tree(page.main_frame)
```

## add_script_tag

```
def add_script_tag(content: nil, path: nil, type: nil, url: nil)
```


Returns the added tag when the script's onload fires or when the script content was injected into frame.

Adds a `<script>` tag into the page with the desired url or content.

## add_style_tag

```
def add_style_tag(content: nil, path: nil, url: nil)
```


Returns the added tag when the stylesheet's onload fires or when the CSS content was injected into frame.

Adds a `<link rel="stylesheet">` tag into the page with the desired url or a `<style type="text/css">` tag with the
content.

## check

```
def check(
      selector,
      force: nil,
      noWaitAfter: nil,
      position: nil,
      strict: nil,
      timeout: nil,
      trial: nil)
```


This method checks an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Ensure that matched element is a checkbox or a radio input. If not, this method throws. If the element is already checked, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Ensure that the element is now checked. If not, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

## child_frames

```
def child_frames
```



## click

```
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
```


This method clicks an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

## content

```
def content
```


Gets the full HTML contents of the frame, including the doctype.

## dblclick

```
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
```


This method double clicks an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to double click in the center of the element, or the specified `position`. if the first click of the `dblclick()` triggers a navigation event, this method will throw.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

**NOTE**: `frame.dblclick()` dispatches two `click` events and a single `dblclick` event.

## dispatch_event

```
def dispatch_event(
      selector,
      type,
      eventInit: nil,
      strict: nil,
      timeout: nil)
```


The snippet below dispatches the `click` event on the element. Regardless of the visibility state of the element, `click`
is dispatched. This is equivalent to calling
[element.click()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/click).

**Usage**

```ruby
frame.dispatch_event("button#submit", "click")
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
data_transfer = frame.evaluate_handle("new DataTransfer()")
frame.dispatch_event("#source", "dragstart", eventInit: { dataTransfer: data_transfer })
```

## drag_and_drop

```
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
```



## eval_on_selector

```
def eval_on_selector(selector, expression, arg: nil, strict: nil)
```


Returns the return value of `expression`.

The method finds an element matching the specified selector within the frame and passes it as a first argument to
`expression`. If no
elements match the selector, the method throws an error.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Frame#eval_on_selector](./frame#eval_on_selector) would wait for the promise to resolve and return its
value.

**Usage**

```ruby
search_value = frame.eval_on_selector("#search", "el => el.value")
preload_href = frame.eval_on_selector("link[rel=preload]", "el => el.href")
html = frame.eval_on_selector(".main-container", "(e, suffix) => e.outerHTML + suffix", arg: "hello")
```

## eval_on_selector_all

```
def eval_on_selector_all(selector, expression, arg: nil)
```


Returns the return value of `expression`.

The method finds all elements matching the specified selector within the frame and passes an array of matched elements
as a first argument to `expression`.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Frame#eval_on_selector_all](./frame#eval_on_selector_all) would wait for the promise to resolve and return its
value.

**Usage**

```ruby
divs_counts = frame.eval_on_selector_all("div", "(divs, min) => divs.length >= min", arg: 10)
```

## evaluate

```
def evaluate(expression, arg: nil)
```


Returns the return value of `expression`.

If the function passed to the [Frame#evaluate](./frame#evaluate) returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Frame#evaluate](./frame#evaluate) would wait for the promise to
resolve and return its value.

If the function passed to the [Frame#evaluate](./frame#evaluate) returns a non-[Serializable](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify#description) value, then
[Frame#evaluate](./frame#evaluate) returns `undefined`. Playwright also supports transferring some
additional values that are not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`.

**Usage**

```ruby
result = frame.evaluate("([x, y]) => Promise.resolve(x * y)", arg: [7, 8])
puts result # => "56"
```

A string can also be passed in instead of a function.

```ruby
puts frame.evaluate("1 + 2") # => 3
x = 10
puts frame.evaluate("1 + #{x}") # => "11"
```

[ElementHandle](./element_handle) instances can be passed as an argument to the [Frame#evaluate](./frame#evaluate):

```ruby
body_handle = frame.query_selector("body")
html = frame.evaluate("([body, suffix]) => body.innerHTML + suffix", arg: [body_handle, "hello"])
body_handle.dispose
```

## evaluate_handle

```
def evaluate_handle(expression, arg: nil)
```


Returns the return value of `expression` as a [JSHandle](./js_handle).

The only difference between [Frame#evaluate](./frame#evaluate) and [Frame#evaluate_handle](./frame#evaluate_handle) is that
[Frame#evaluate_handle](./frame#evaluate_handle) returns [JSHandle](./js_handle).

If the function, passed to the [Frame#evaluate_handle](./frame#evaluate_handle), returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then
[Frame#evaluate_handle](./frame#evaluate_handle) would wait for the promise to resolve and return its value.

**Usage**

```ruby
a_window_handle = frame.evaluate_handle("Promise.resolve(window)")
a_window_handle # handle for the window object.
```

A string can also be passed in instead of a function.

```ruby
a_handle = page.evaluate_handle("document") # handle for the "document"
```

[JSHandle](./js_handle) instances can be passed as an argument to the [Frame#evaluate_handle](./frame#evaluate_handle):

```ruby
body_handle = page.evaluate_handle("document.body")
result_handle = page.evaluate_handle("body => body.innerHTML", arg: body_handle)
puts result_handle.json_value
result_handle.dispose
```

## fill

```
def fill(
      selector,
      value,
      force: nil,
      noWaitAfter: nil,
      strict: nil,
      timeout: nil)
```


This method waits for an element matching `selector`, waits for [actionability](https://playwright.dev/python/docs/actionability) checks, focuses the element, fills it and triggers an `input` event after filling. Note that you can pass an empty string to clear the input field.

If the target element is not an `<input>`, `<textarea>` or `[contenteditable]` element, this method throws an error. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be filled instead.

To send fine-grained keyboard events, use [Locator#press_sequentially](./locator#press_sequentially).

## focus

```
def focus(selector, strict: nil, timeout: nil)
```


This method fetches an element with `selector` and focuses it. If there's no element matching
`selector`, the method waits until a matching element appears in the DOM.

## frame_element

```
def frame_element
```


Returns the `frame` or `iframe` element handle which corresponds to this frame.

This is an inverse of [ElementHandle#content_frame](./element_handle#content_frame). Note that returned handle actually belongs to the parent
frame.

This method throws an error if the frame has been detached before `frameElement()` returns.

**Usage**

```ruby
frame_element = frame.frame_element
content_frame = frame_element.content_frame
puts frame == content_frame # => true
```

## frame_locator

```
def frame_locator(selector)
```


When working with iframes, you can create a frame locator that will enter the iframe and allow selecting elements
in that iframe.

**Usage**

Following snippet locates element with text "Submit" in the iframe with id `my-frame`, like `<iframe id="my-frame">`:

```ruby
locator = frame.frame_locator("#my-iframe").get_by_text("Submit")
locator.click
```

## get_attribute

```
def get_attribute(selector, name, strict: nil, timeout: nil)
```


Returns element attribute value.

## get_by_alt_text

```
def get_by_alt_text(text, exact: nil)
```


Allows locating elements by their alt text.

**Usage**

For example, this method will find the image by alt text "Playwright logo":

```html
<img alt='Playwright logo'>
```

```ruby
page.get_by_alt_text("Playwright logo").click
```

## get_by_label

```
def get_by_label(text, exact: nil)
```


Allows locating input elements by the text of the associated `<label>` or `aria-labelledby` element, or by the `aria-label` attribute.

**Usage**

For example, this method will find inputs by label "Username" and "Password" in the following DOM:

```html
<input aria-label="Username">
<label for="password-input">Password:</label>
<input id="password-input">
```

```ruby
page.get_by_label("Username").fill("john")
page.get_by_label("Password").fill("secret")
```

## get_by_placeholder

```
def get_by_placeholder(text, exact: nil)
```


Allows locating input elements by the placeholder text.

**Usage**

For example, consider the following DOM structure.

```html
<input type="email" placeholder="name@example.com" />
```

You can fill the input after locating it by the placeholder text:

```ruby
page.get_by_placeholder("name@example.com").fill("playwright@microsoft.com")
```

## get_by_role

```
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
```


Allows locating elements by their [ARIA role](https://www.w3.org/TR/wai-aria-1.2/#roles), [ARIA attributes](https://www.w3.org/TR/wai-aria-1.2/#aria-attributes) and [accessible name](https://w3c.github.io/accname/#dfn-accessible-name).

**Usage**

Consider the following DOM structure.

```html
<h3>Sign up</h3>
<label>
  <input type="checkbox" /> Subscribe
</label>
<br/>
<button>Submit</button>
```

You can locate each element by it's implicit role:

```ruby
page.get_by_role("heading", name: "Sign up").visible? # => true
page.get_by_role("checkbox", name: "Subscribe").check
page.get_by_role("button", name: /submit/i).click
```

**Details**

Role selector **does not replace** accessibility audits and conformance tests, but rather gives early feedback about the ARIA guidelines.

Many html elements have an implicitly [defined role](https://w3c.github.io/html-aam/#html-element-role-mappings) that is recognized by the role selector. You can find all the [supported roles here](https://www.w3.org/TR/wai-aria-1.2/#role_definitions). ARIA guidelines **do not recommend** duplicating implicit roles and attributes by setting `role` and/or `aria-*` attributes to default values.

## get_by_test_id

```
def get_by_test_id(testId)
```
alias: `get_by_testid`


Locate element by the test id.

**Usage**

Consider the following DOM structure.

```html
<button data-testid="directions">Itinéraire</button>
```

You can locate the element by it's test id:

```ruby
page.get_by_test_id("directions").click
```

**Details**

By default, the `data-testid` attribute is used as a test id. Use [Selectors#set_test_id_attribute](./selectors#set_test_id_attribute) to configure a different test id attribute if necessary.

## get_by_text

```
def get_by_text(text, exact: nil)
```


Allows locating elements that contain given text.

See also [Locator#filter](./locator#filter) that allows to match by another criteria, like an accessible role, and then filter by the text content.

**Usage**

Consider the following DOM structure:

```html
<div>Hello <span>world</span></div>
<div>Hello</div>
```

You can locate by text substring, exact string, or a regular expression:

```ruby
page.content = <<~HTML
  <div>Hello <span>world</span></div>
  <div>Hello</div>
HTML

# Matches <span>
locator = page.get_by_text("world")
expect(locator.evaluate('e => e.outerHTML')).to eq('<span>world</span>')

# Matches first <div>
locator = page.get_by_text("Hello world")
expect(locator.evaluate('e => e.outerHTML')).to eq('<div>Hello <span>world</span></div>')

# Matches second <div>
locator = page.get_by_text("Hello", exact: true)
expect(locator.evaluate('e => e.outerHTML')).to eq('<div>Hello</div>')

# Matches both <div>s
locator = page.get_by_text(/Hello/)
expect(locator.count).to eq(2)
expect(locator.first.evaluate('e => e.outerHTML')).to eq('<div>Hello <span>world</span></div>')
expect(locator.last.evaluate('e => e.outerHTML')).to eq('<div>Hello</div>')

# Matches second <div>
locator = page.get_by_text(/^hello$/i)
expect(locator.evaluate('e => e.outerHTML')).to eq('<div>Hello</div>')
```

**Details**

Matching by text always normalizes whitespace, even with exact match. For example, it turns multiple spaces into one, turns line breaks into spaces and ignores leading and trailing whitespace.

Input elements of the type `button` and `submit` are matched by their `value` instead of the text content. For example, locating by text `"Log in"` matches `<input type=button value="Log in">`.

## get_by_title

```
def get_by_title(text, exact: nil)
```


Allows locating elements by their title attribute.

**Usage**

Consider the following DOM structure.

```html
<span title='Issues count'>25 issues</span>
```

You can check the issues count after locating it by the title text:

```ruby
page.get_by_title("Issues count").text_content # => "25 issues"
```

## goto

```
def goto(url, referer: nil, timeout: nil, waitUntil: nil)
```


Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
last redirect.

The method will throw an error if:
- there's an SSL error (e.g. in case of self-signed certificates).
- target URL is invalid.
- the `timeout` is exceeded during navigation.
- the remote server does not respond or is unreachable.
- the main resource failed to load.

The method will not throw an error when any valid HTTP status code is returned by the remote server, including 404
"Not Found" and 500 "Internal Server Error".  The status code for such responses can be retrieved by calling
[Response#status](./response#status).

**NOTE**: The method either throws an error or returns a main resource response. The only exceptions are navigation to
`about:blank` or navigation to the same URL with a different hash, which would succeed and return `null`.

**NOTE**: Headless mode doesn't support navigation to a PDF document. See the
[upstream issue](https://bugs.chromium.org/p/chromium/issues/detail?id=761295).

## hover

```
def hover(
      selector,
      force: nil,
      modifiers: nil,
      noWaitAfter: nil,
      position: nil,
      strict: nil,
      timeout: nil,
      trial: nil)
```


This method hovers over an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to hover over the center of the element, or the specified `position`.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

## inner_html

```
def inner_html(selector, strict: nil, timeout: nil)
```


Returns `element.innerHTML`.

## inner_text

```
def inner_text(selector, strict: nil, timeout: nil)
```


Returns `element.innerText`.

## input_value

```
def input_value(selector, strict: nil, timeout: nil)
```


Returns `input.value` for the selected `<input>` or `<textarea>` or `<select>` element.

Throws for non-input elements. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), returns the value of the control.

## checked?

```
def checked?(selector, strict: nil, timeout: nil)
```


Returns whether the element is checked. Throws if the element is not a checkbox or radio input.

## detached?

```
def detached?
```


Returns `true` if the frame has been detached, or `false` otherwise.

## disabled?

```
def disabled?(selector, strict: nil, timeout: nil)
```


Returns whether the element is disabled, the opposite of [enabled](https://playwright.dev/python/docs/actionability#enabled).

## editable?

```
def editable?(selector, strict: nil, timeout: nil)
```


Returns whether the element is [editable](https://playwright.dev/python/docs/actionability#editable).

## enabled?

```
def enabled?(selector, strict: nil, timeout: nil)
```


Returns whether the element is [enabled](https://playwright.dev/python/docs/actionability#enabled).

## hidden?

```
def hidden?(selector, strict: nil, timeout: nil)
```


Returns whether the element is hidden, the opposite of [visible](https://playwright.dev/python/docs/actionability#visible).  `selector` that does not match any elements is considered hidden.

## visible?

```
def visible?(selector, strict: nil, timeout: nil)
```


Returns whether the element is [visible](https://playwright.dev/python/docs/actionability#visible). `selector` that does not match any elements is considered not visible.

## locator

```
def locator(
      selector,
      has: nil,
      hasNot: nil,
      hasNotText: nil,
      hasText: nil)
```


The method returns an element locator that can be used to perform actions on this page / frame.
Locator is resolved to the element immediately before performing an action, so a series of actions on the same locator can in fact be performed on different DOM elements. That would happen if the DOM structure between those actions has changed.

[Learn more about locators](https://playwright.dev/python/docs/locators).

[Learn more about locators](https://playwright.dev/python/docs/locators).

## name

```
def name
```


Returns frame's name attribute as specified in the tag.

If the name is empty, returns the id attribute instead.

**NOTE**: This value is calculated once when the frame is created, and will not update if the attribute is changed later.

## page

```
def page
```


Returns the page containing this frame.

## parent_frame

```
def parent_frame
```


Parent frame, if any. Detached frames and main frames return `null`.

## press

```
def press(
      selector,
      key,
      delay: nil,
      noWaitAfter: nil,
      strict: nil,
      timeout: nil)
```


`key` can specify the intended
[keyboardEvent.key](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key) value or a single character to
generate the text for. A superset of the `key` values can be found
[here](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values). Examples of the keys are:

`F1` - `F12`, `Digit0`- `Digit9`, `KeyA`- `KeyZ`, `Backquote`, `Minus`, `Equal`, `Backslash`, `Backspace`, `Tab`,
`Delete`, `Escape`, `ArrowDown`, `End`, `Enter`, `Home`, `Insert`, `PageDown`, `PageUp`, `ArrowRight`, `ArrowUp`, etc.

Following modification shortcuts are also supported: `Shift`, `Control`, `Alt`, `Meta`, `ShiftLeft`, `ControlOrMeta`.
`ControlOrMeta` resolves to `Control` on Windows and Linux and to `Meta` on macOS.

Holding down `Shift` will type the text that corresponds to the `key` in the upper case.

If `key` is a single character, it is case-sensitive, so the values `a` and `A` will generate different
respective texts.

Shortcuts such as `key: "Control+o"`, `key: "Control++` or `key: "Control+Shift+T"` are supported as well. When specified with the
modifier, modifier is pressed and being held while the subsequent key is being pressed.

## query_selector

```
def query_selector(selector, strict: nil)
```


Returns the ElementHandle pointing to the frame element.

**NOTE**: The use of [ElementHandle](./element_handle) is discouraged, use [Locator](./locator) objects and web-first assertions instead.

The method finds an element matching the specified selector within the frame. If no elements match the selector,
returns `null`.

## query_selector_all

```
def query_selector_all(selector)
```


Returns the ElementHandles pointing to the frame elements.

**NOTE**: The use of [ElementHandle](./element_handle) is discouraged, use [Locator](./locator) objects instead.

The method finds all elements matching the specified selector within the frame. If no elements match the selector,
returns empty array.

## select_option

```
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
```


This method waits for an element matching `selector`, waits for [actionability](https://playwright.dev/python/docs/actionability) checks, waits until all specified options are present in the `<select>` element and selects these options.

If the target element is not a `<select>` element, this method throws an error. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be used instead.

Returns the array of option values that have been successfully selected.

Triggers a `change` and `input` event once all the provided options have been selected.

**Usage**

```ruby
# single selection matching the value
frame.select_option("select#colors", value: "blue")
# single selection matching both the label
frame.select_option("select#colors", label: "blue")
# multiple selection
frame.select_option("select#colors", value: ["red", "green", "blue"])
```

## set_checked

```
def set_checked(
      selector,
      checked,
      force: nil,
      noWaitAfter: nil,
      position: nil,
      strict: nil,
      timeout: nil,
      trial: nil)
```


This method checks or unchecks an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Ensure that matched element is a checkbox or a radio input. If not, this method throws.
1. If the element already has the right checked state, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Ensure that the element is now checked or unchecked. If not, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

## set_content

```
def set_content(html, timeout: nil, waitUntil: nil)
```
alias: `content=`


This method internally calls [document.write()](https://developer.mozilla.org/en-US/docs/Web/API/Document/write), inheriting all its specific characteristics and behaviors.

## set_input_files

```
def set_input_files(
      selector,
      files,
      noWaitAfter: nil,
      strict: nil,
      timeout: nil)
```


Sets the value of the file input to these file paths or files. If some of the `filePaths` are relative paths, then they
are resolved relative to the current working directory. For empty array, clears the selected files.

This method expects `selector` to point to an
[input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input). However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), targets the control instead.

## tap_point

```
def tap_point(
      selector,
      force: nil,
      modifiers: nil,
      noWaitAfter: nil,
      position: nil,
      strict: nil,
      timeout: nil,
      trial: nil)
```


This method taps an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#touchscreen](./page#touchscreen) to tap the center of the element, or the specified `position`.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

**NOTE**: `frame.tap()` requires that the `hasTouch` option of the browser context be set to true.

## text_content

```
def text_content(selector, strict: nil, timeout: nil)
```


Returns `element.textContent`.

## title

```
def title
```


Returns the page title.

## type

```
def type(
      selector,
      text,
      delay: nil,
      noWaitAfter: nil,
      strict: nil,
      timeout: nil)
```

:::warning

In most cases, you should use [Locator#fill](./locator#fill) instead. You only need to press keys one by one if there is special keyboard handling on the page - in this case use [Locator#press_sequentially](./locator#press_sequentially).

:::


Sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text. `frame.type` can be used to
send fine-grained keyboard events. To fill values in form fields, use [Frame#fill](./frame#fill).

To press a special key, like `Control` or `ArrowDown`, use [Keyboard#press](./keyboard#press).

**Usage**

## uncheck

```
def uncheck(
      selector,
      force: nil,
      noWaitAfter: nil,
      position: nil,
      strict: nil,
      timeout: nil,
      trial: nil)
```


This method checks an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Ensure that matched element is a checkbox or a radio input. If not, this method throws. If the element is already unchecked, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Ensure that the element is now unchecked. If not, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

## url

```
def url
```


Returns frame's url.

## wait_for_function

```
def wait_for_function(expression, arg: nil, polling: nil, timeout: nil)
```


Returns when the `expression` returns a truthy value, returns that value.

**Usage**

The [Frame#wait_for_function](./frame#wait_for_function) can be used to observe viewport size change:

```ruby
frame.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
frame.wait_for_function("() => window.x > 0")
```

To pass an argument to the predicate of `frame.waitForFunction` function:

```ruby
selector = ".foo"
frame.wait_for_function("selector => !!document.querySelector(selector)", arg: selector)
```

## wait_for_load_state

```
def wait_for_load_state(state: nil, timeout: nil)
```


Waits for the required load state to be reached.

This returns when the frame reaches a required load state, `load` by default. The navigation must have been committed
when this method is called. If current document has already reached the required state, resolves immediately.

**NOTE**: Most of the time, this method is not needed because Playwright [auto-waits before every action](https://playwright.dev/python/docs/actionability).

**Usage**

```ruby
frame.click("button") # click triggers navigation.
frame.wait_for_load_state # the promise resolves after "load" event.
```

## expect_navigation

```
def expect_navigation(timeout: nil, url: nil, waitUntil: nil, &block)
```

:::warning

This method is inherently racy, please use [Frame#wait_for_url](./frame#wait_for_url) instead.

:::


Waits for the frame navigation and returns the main resource response. In case of multiple redirects, the navigation
will resolve with the response of the last redirect. In case of navigation to a different anchor or navigation due to
History API usage, the navigation will resolve with `null`.

**Usage**

This method waits for the frame to navigate to a new URL. It is useful for when you run code which will indirectly cause
the frame to navigate. Consider this example:

```ruby
frame.expect_navigation do
  frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
end # Resolves after navigation has finished
```

**NOTE**: Usage of the [History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API) to change the URL is considered
a navigation.

## wait_for_selector

```
def wait_for_selector(selector, state: nil, strict: nil, timeout: nil)
```


Returns when element specified by selector satisfies `state` option. Returns `null` if waiting for `hidden` or
`detached`.

**NOTE**: Playwright automatically waits for element to be ready before performing an action. Using
[Locator](./locator) objects and web-first assertions make the code wait-for-selector-free.

Wait for the `selector` to satisfy `state` option (either appear/disappear from dom, or become
visible/hidden). If at the moment of calling the method `selector` already satisfies the condition, the method
will return immediately. If the selector doesn't satisfy the condition for the `timeout` milliseconds, the
function will throw.

**Usage**

This method works across navigations:

```ruby
%w[https://google.com https://bbc.com].each do |current_url|
  page.goto(current_url, waitUntil: "domcontentloaded")
  frame = page.main_frame
  element = frame.wait_for_selector("img")
  puts "Loaded image: #{element["src"]}"
end
```

## wait_for_timeout

```
def wait_for_timeout(timeout)
```


Waits for the given `timeout` in milliseconds.

Note that `frame.waitForTimeout()` should only be used for debugging. Tests using the timer in production are going to
be flaky. Use signals such as network events, selectors becoming visible and others instead.

## wait_for_url

```
def wait_for_url(url, timeout: nil, waitUntil: nil)
```


Waits for the frame to navigate to the given URL.

**Usage**

```ruby
frame.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
frame.wait_for_url("**/target.html")
```
