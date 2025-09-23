---
sidebar_position: 10
---

# Page


Page provides methods to interact with a single tab in a [Browser](./browser), or an
[extension background page](https://developer.chrome.com/extensions/background_pages) in Chromium. One [Browser](./browser)
instance might have multiple [Page](./page) instances.

This example creates a page, navigates it to a URL, and then saves a screenshot:

```ruby
playwright.webkit.launch do |browser|
  page = browser.new_page
  page.goto('https://example.com/')
  page.screenshot(path: 'screenshot.png')
end
```

The Page class emits various events (described below) which can be handled using any of Node's native
[`EventEmitter`](https://nodejs.org/api/events.html#events_class_eventemitter) methods, such as `on`, `once` or
`removeListener`.

This example logs a message for a single page `load` event:

```ruby
page.once("load", -> (page) { puts "page loaded!" })
```

To unsubscribe from events use the `removeListener` method:

```ruby
listener = -> (req) { puts "a request was made: #{req.url}" }
page.on('request', listener)
page.goto('https://example.com/') # => prints 'a request was made: https://example.com/'
page.off('request', listener)
page.goto('https://example.com/') # => no print
```

## add_init_script

```
def add_init_script(path: nil, script: nil)
```


Adds a script which would be evaluated in one of the following scenarios:
- Whenever the page is navigated.
- Whenever the child frame is attached or navigated. In this case, the script is evaluated in the context of the newly attached frame.

The script is evaluated after the document was created but before any of its scripts were run. This is useful to amend
the JavaScript environment, e.g. to seed `Math.random`.

**Usage**

An example of overriding `Math.random` before the page loads:

```ruby
# in your playwright script, assuming the preload.js file is in same directory
page.add_init_script(path: "./preload.js")
```

**NOTE**: The order of evaluation of multiple scripts installed via [BrowserContext#add_init_script](./browser_context#add_init_script) and
[Page#add_init_script](./page#add_init_script) is not defined.

## add_script_tag

```
def add_script_tag(content: nil, path: nil, type: nil, url: nil)
```


Adds a `<script>` tag into the page with the desired url or content. Returns the added tag when the script's onload
fires or when the script content was injected into frame.

## add_style_tag

```
def add_style_tag(content: nil, path: nil, url: nil)
```


Adds a `<link rel="stylesheet">` tag into the page with the desired url or a `<style type="text/css">` tag with the
content. Returns the added tag when the stylesheet's onload fires or when the CSS content was injected into frame.

## bring_to_front

```
def bring_to_front
```


Brings page to front (activates tab).

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

## close

```
def close(reason: nil, runBeforeUnload: nil)
```


If `runBeforeUnload` is `false`, does not run any unload handlers and waits for the page to be closed. If
`runBeforeUnload` is `true` the method will run unload handlers, but will **not** wait for the page to close.

By default, `page.close()` **does not** run `beforeunload` handlers.

**NOTE**: if `runBeforeUnload` is passed as true, a `beforeunload` dialog might be summoned and should be handled
manually via [`event: Page.dialog`] event.

## content

```
def content
```


Gets the full HTML contents of the page, including the doctype.

## context

```
def context
```


Get the browser context that the page belongs to.

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
1. Use [Page#mouse](./page#mouse) to double click in the center of the element, or the specified `position`.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

**NOTE**: `page.dblclick()` dispatches two `click` events and a single `dblclick` event.

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
page.content = '<button id="submit">Send</button>'
page.dispatch_event("button#submit", "click")
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
page.content = '<div id="source">Drag</div>'

data_transfer = page.evaluate_handle("new DataTransfer()")
page.dispatch_event("#source", "dragstart", eventInit: { dataTransfer: data_transfer })
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


This method drags the source element to the target element.
It will first move to the source element, perform a `mousedown`,
then move to the target element and perform a `mouseup`.

**Usage**

```ruby
page.drag_and_drop("#source", "#target")
# or specify exact positions relative to the top-left corners of the elements:
page.drag_and_drop(
  "#source",
  "#target",
  sourcePosition: { x: 34, y: 7 },
  targetPosition: { x: 10, y: 20 },
)
```

## emulate_media

```
def emulate_media(
      colorScheme: nil,
      contrast: nil,
      forcedColors: nil,
      media: nil,
      reducedMotion: nil)
```


This method changes the `CSS media type` through the `media` argument, and/or the `'prefers-colors-scheme'` media feature, using the `colorScheme` argument.

**Usage**

```ruby
page.evaluate("matchMedia('screen').matches") # => true
page.evaluate("matchMedia('print').matches") # => false

page.emulate_media(media: "print")
page.evaluate("matchMedia('screen').matches") # => false
page.evaluate("matchMedia('print').matches") # => true

page.emulate_media
page.evaluate("matchMedia('screen').matches") # => true
page.evaluate("matchMedia('print').matches") # => false
```

```ruby
page.emulate_media(colorScheme: "dark")
page.evaluate("matchMedia('(prefers-color-scheme: dark)').matches") # => true
page.evaluate("matchMedia('(prefers-color-scheme: light)').matches") # => false
```

## eval_on_selector

```
def eval_on_selector(selector, expression, arg: nil, strict: nil)
```


The method finds an element matching the specified selector within the page and passes it as a first argument to
`expression`. If no elements match the selector, the method throws an error. Returns the value of
`expression`.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Page#eval_on_selector](./page#eval_on_selector) would wait for the promise to resolve and
return its value.

**Usage**

```ruby
search_value = page.eval_on_selector("#search", "el => el.value")
preload_href = page.eval_on_selector("link[rel=preload]", "el => el.href")
html = page.eval_on_selector(".main-container", "(e, suffix) => e.outer_html + suffix", arg: "hello")
```

## eval_on_selector_all

```
def eval_on_selector_all(selector, expression, arg: nil)
```


The method finds all elements matching the specified selector within the page and passes an array of matched elements as
a first argument to `expression`. Returns the result of `expression` invocation.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Page#eval_on_selector_all](./page#eval_on_selector_all) would wait for the promise to resolve and
return its value.

**Usage**

```ruby
div_counts = page.eval_on_selector_all("div", "(divs, min) => divs.length >= min", arg: 10)
```

## evaluate

```
def evaluate(expression, arg: nil)
```


Returns the value of the `expression` invocation.

If the function passed to the [Page#evaluate](./page#evaluate) returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Page#evaluate](./page#evaluate) would wait
for the promise to resolve and return its value.

If the function passed to the [Page#evaluate](./page#evaluate) returns a non-[Serializable](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify#description) value, then
[Page#evaluate](./page#evaluate) resolves to `undefined`. Playwright also supports transferring some
additional values that are not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`.

**Usage**

Passing argument to `expression`:

```ruby
result = page.evaluate("([x, y]) => Promise.resolve(x * y)", arg: [7, 8])
puts result # => "56"
```

A string can also be passed in instead of a function:

```ruby
puts page.evaluate("1 + 2") # => 3
x = 10
puts page.evaluate("1 + #{x}") # => "11"
```

[ElementHandle](./element_handle) instances can be passed as an argument to the [Page#evaluate](./page#evaluate):

```ruby
body_handle = page.query_selector("body")
html = page.evaluate("([body, suffix]) => body.innerHTML + suffix", arg: [body_handle, "hello"])
body_handle.dispose
```

## evaluate_handle

```
def evaluate_handle(expression, arg: nil)
```


Returns the value of the `expression` invocation as a [JSHandle](./js_handle).

The only difference between [Page#evaluate](./page#evaluate) and [Page#evaluate_handle](./page#evaluate_handle) is that [Page#evaluate_handle](./page#evaluate_handle) returns [JSHandle](./js_handle).

If the function passed to the [Page#evaluate_handle](./page#evaluate_handle) returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Page#evaluate_handle](./page#evaluate_handle) would wait for the
promise to resolve and return its value.

**Usage**

```ruby
a_window_handle = page.evaluate_handle("Promise.resolve(window)")
a_window_handle # handle for the window object.
```

A string can also be passed in instead of a function:

```ruby
a_handle = page.evaluate_handle("document") # handle for the "document"
```

[JSHandle](./js_handle) instances can be passed as an argument to the [Page#evaluate_handle](./page#evaluate_handle):

```ruby
body_handle = page.evaluate_handle("document.body")
result_handle = page.evaluate_handle("body => body.innerHTML", arg: body_handle)
puts result_handle.json_value
result_handle.dispose
```

## expose_binding

```
def expose_binding(name, callback, handle: nil)
```


The method adds a function called `name` on the `window` object of every frame in this page. When called, the
function executes `callback` and returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) which resolves to the return value of `callback`.
If the `callback` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), it will be awaited.

The first argument of the `callback` function contains information about the caller: `{ browserContext:
BrowserContext, page: Page, frame: Frame }`.

See [BrowserContext#expose_binding](./browser_context#expose_binding) for the context-wide version.

**NOTE**: Functions installed via [Page#expose_binding](./page#expose_binding) survive navigations.

**Usage**

An example of exposing page URL to all frames in a page:

```ruby
page.expose_binding("pageURL", ->(source) { source[:page].url })
page.content = <<~HTML
<script>
  async function onClick() {
    document.querySelector('div').textContent = await window.pageURL();
  }
</script>
<button onclick="onClick()">Click me</button>
<div></div>
HTML
page.click("button")
```

## expose_function

```
def expose_function(name, callback)
```


The method adds a function called `name` on the `window` object of every frame in the page. When called, the
function executes `callback` and returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise) which resolves to the return value of `callback`.

If the `callback` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), it will be awaited.

See [BrowserContext#expose_function](./browser_context#expose_function) for context-wide exposed function.

**NOTE**: Functions installed via [Page#expose_function](./page#expose_function) survive navigations.

**Usage**

An example of adding a `sha256` function to the page:

```ruby
require 'digest'

def sha256(text)
  Digest::SHA256.hexdigest(text)
end

page.expose_function("sha256", method(:sha256))
page.content = <<~HTML
<script>
  async function onClick() {
    document.querySelector('div').textContent = await window.sha256('PLAYWRIGHT');
  }
</script>
<button onclick="onClick()">Click me</button>
<div></div>
HTML
page.locator("button").click
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

## frame

```
def frame(name: nil, url: nil)
```


Returns frame matching the specified criteria. Either `name` or `url` must be specified.

**Usage**

```ruby
frame = page.frame(name: "frame-name")
```

```ruby
frame = page.frame(url: /.*domain.*/)
```

## frame_locator

```
def frame_locator(selector)
```


When working with iframes, you can create a frame locator that will enter the iframe and allow selecting elements
in that iframe.

**Usage**

Following snippet locates element with text "Submit" in the iframe with id `my-frame`,
like `<iframe id="my-frame">`:

```ruby
locator = page.frame_locator("#my-iframe").get_by_text("Submit")
locator.click
```

## frames

```
def frames
```


An array of all frames attached to the page.

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

## go_back

```
def go_back(timeout: nil, waitUntil: nil)
```


Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
last redirect. If cannot go back, returns `null`.

Navigate to the previous page in history.

## go_forward

```
def go_forward(timeout: nil, waitUntil: nil)
```


Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
last redirect. If cannot go forward, returns `null`.

Navigate to the next page in history.

## goto

```
def goto(url, referer: nil, timeout: nil, waitUntil: nil)
```


Returns the main resource response. In case of multiple redirects, the navigation will resolve with the first
non-redirect response.

The method will throw an error if:
- there's an SSL error (e.g. in case of self-signed certificates).
- target URL is invalid.
- the `timeout` is exceeded during navigation.
- the remote server does not respond or is unreachable.
- the main resource failed to load.

The method will not throw an error when any valid HTTP status code is returned by the remote server, including 404 "Not
Found" and 500 "Internal Server Error".  The status code for such responses can be retrieved by calling
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

## closed?

```
def closed?
```


Indicates that the page has been closed.

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

## main_frame

```
def main_frame
```


The page's main frame. Page is guaranteed to have a main frame which persists during navigations.

## opener

```
def opener
```


Returns the opener for popup pages and `null` for others. If the opener has been closed already the returns `null`.

## pause

```
def pause
```


Pauses script execution. Playwright will stop executing the script and wait for the user to either press the 'Resume'
button in the page overlay or to call `playwright.resume()` in the DevTools console.

User can inspect selectors or perform manual steps while paused. Resume will continue running the original script from
the place it was paused.

**NOTE**: This method requires Playwright to be started in a headed mode, with a falsy `headless` option.

## pdf

```
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
```


Returns the PDF buffer.

`page.pdf()` generates a pdf of the page with `print` css media. To generate a pdf with `screen` media, call
[Page#emulate_media](./page#emulate_media) before calling `page.pdf()`:

**NOTE**: By default, `page.pdf()` generates a pdf with modified colors for printing. Use the
[`-webkit-print-color-adjust`](https://developer.mozilla.org/en-US/docs/Web/CSS/-webkit-print-color-adjust) property to
force rendering of exact colors.

**Usage**

```ruby
# generates a pdf with "screen" media type.
page.emulate_media(media: "screen")
page.pdf(path: "page.pdf")
```

The `width`, `height`, and `margin` options accept values labeled with units. Unlabeled
values are treated as pixels.

A few examples:
- `page.pdf({width: 100})` - prints with width set to 100 pixels
- `page.pdf({width: '100px'})` - prints with width set to 100 pixels
- `page.pdf({width: '10cm'})` - prints with width set to 10 centimeters.

All possible units are:
- `px` - pixel
- `in` - inch
- `cm` - centimeter
- `mm` - millimeter

The `format` options are:
- `Letter`: 8.5in x 11in
- `Legal`: 8.5in x 14in
- `Tabloid`: 11in x 17in
- `Ledger`: 17in x 11in
- `A0`: 33.1in x 46.8in
- `A1`: 23.4in x 33.1in
- `A2`: 16.54in x 23.4in
- `A3`: 11.7in x 16.54in
- `A4`: 8.27in x 11.7in
- `A5`: 5.83in x 8.27in
- `A6`: 4.13in x 5.83in

**NOTE**: `headerTemplate` and `footerTemplate` markup have the following limitations: > 1. Script tags inside
templates are not evaluated. > 2. Page styles are not visible inside templates.

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


Focuses the element, and then uses [Keyboard#down](./keyboard#down) and [Keyboard#up](./keyboard#up).

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

**Usage**

```ruby
page.goto("https://keycode.info")
page.press("body", "A")
page.screenshot(path: "a.png")
page.press("body", "ArrowLeft")
page.screenshot(path: "arrow_left.png")
page.press("body", "Shift+O")
page.screenshot(path: "o.png")
```

## query_selector

```
def query_selector(selector, strict: nil)
```


The method finds an element matching the specified selector within the page. If no elements match the selector, the
return value resolves to `null`. To wait for an element on the page, use [Locator#wait_for](./locator#wait_for).

## query_selector_all

```
def query_selector_all(selector)
```


The method finds all elements matching the specified selector within the page. If no elements match the selector, the
return value resolves to `[]`.

## reload

```
def reload(timeout: nil, waitUntil: nil)
```


This method reloads the current page, in the same way as if the user had triggered a browser refresh.
Returns the main resource response. In case of multiple redirects, the navigation will resolve with the response of the
last redirect.

## route

```
def route(url, handler, times: nil)
```


Routing provides the capability to modify network requests that are made by a page.

Once routing is enabled, every request matching the url pattern will stall unless it's continued, fulfilled or aborted.

**NOTE**: The handler will only be called for the first url if the response is a redirect.

**NOTE**: [Page#route](./page#route) will not intercept requests intercepted by Service Worker. See [this](https://github.com/microsoft/playwright/issues/1090) issue. We recommend disabling Service Workers when using request interception by setting `serviceWorkers` to `'block'`.

**NOTE**: [Page#route](./page#route) will not intercept the first request of a popup page. Use [BrowserContext#route](./browser_context#route) instead.

**Usage**

An example of a naive handler that aborts all image requests:

```ruby
page.route("**/*.{png,jpg,jpeg}", ->(route, request) { route.abort })
page.goto("https://example.com")
```

or the same snippet using a regex pattern instead:

```ruby
page.route(/\.(png|jpg)$/, ->(route, request) { route.abort })
page.goto("https://example.com")
```

It is possible to examine the request to decide the route action. For example, mocking all requests that contain some post data, and leaving all other requests as is:

```ruby
def handle_route(route, request)
  if request.post_data["my-string"]
    mocked_data = request.post_data.merge({ "my-string" => 'mocked-data'})
    route.fulfill(postData: mocked_data)
  else
    route.continue
  end
end
page.route("/api/**", method(:handle_route))
```

Page routes take precedence over browser context routes (set up with [BrowserContext#route](./browser_context#route)) when request
matches both handlers.

To remove a route with its handler you can use [Page#unroute](./page#unroute).

**NOTE**: Enabling routing disables http cache.

## route_from_har

```
def route_from_har(
      har,
      notFound: nil,
      update: nil,
      updateContent: nil,
      updateMode: nil,
      url: nil)
```


If specified the network requests that are made in the page will be served from the HAR file. Read more about [Replaying from HAR](https://playwright.dev/python/docs/mock#replaying-from-har).

Playwright will not serve requests intercepted by Service Worker from the HAR file. See [this](https://github.com/microsoft/playwright/issues/1090) issue. We recommend disabling Service Workers when using request interception by setting `serviceWorkers` to `'block'`.

## screenshot

```
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
```


Returns the buffer with the captured screenshot.

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
page.select_option("select#colors", value: "blue")
# single selection matching both the label
page.select_option("select#colors", label: "blue")
# multiple selection
page.select_option("select#colors", value: ["red", "green", "blue"])
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

## set_default_navigation_timeout

```
def set_default_navigation_timeout(timeout)
```
alias: `default_navigation_timeout=`


This setting will change the default maximum navigation time for the following methods and related shortcuts:
- [Page#go_back](./page#go_back)
- [Page#go_forward](./page#go_forward)
- [Page#goto](./page#goto)
- [Page#reload](./page#reload)
- [Page#set_content](./page#set_content)
- [Page#expect_navigation](./page#expect_navigation)
- [Page#wait_for_url](./page#wait_for_url)

**NOTE**: [Page#set_default_navigation_timeout](./page#set_default_navigation_timeout) takes priority over [Page#set_default_timeout](./page#set_default_timeout),
[BrowserContext#set_default_timeout](./browser_context#set_default_timeout) and [BrowserContext#set_default_navigation_timeout](./browser_context#set_default_navigation_timeout).

## set_default_timeout

```
def set_default_timeout(timeout)
```
alias: `default_timeout=`


This setting will change the default maximum time for all the methods accepting `timeout` option.

**NOTE**: [Page#set_default_navigation_timeout](./page#set_default_navigation_timeout) takes priority over [Page#set_default_timeout](./page#set_default_timeout).

## set_extra_http_headers

```
def set_extra_http_headers(headers)
```
alias: `extra_http_headers=`


The extra HTTP headers will be sent with every request the page initiates.

**NOTE**: [Page#set_extra_http_headers](./page#set_extra_http_headers) does not guarantee the order of headers in the outgoing requests.

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
For inputs with a `[webkitdirectory]` attribute, only a single directory path is supported.

This method expects `selector` to point to an
[input element](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input). However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), targets the control instead.

## set_viewport_size

```
def set_viewport_size(viewportSize)
```
alias: `viewport_size=`


In the case of multiple pages in a single browser, each page can have its own viewport size. However,
[Browser#new_context](./browser#new_context) allows to set viewport size (and more) for all pages in the context at once.

[Page#set_viewport_size](./page#set_viewport_size) will resize the page. A lot of websites don't expect phones to change size, so you should set the
viewport size before navigating to the page. [Page#set_viewport_size](./page#set_viewport_size) will also reset `screen` size, use [Browser#new_context](./browser#new_context) with `screen` and `viewport` parameters if you need better control of these properties.

**Usage**

```ruby
page.viewport_size = { width: 640, height: 480 }
page.goto("https://example.com")
```

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

**NOTE**: [Page#tap_point](./page#tap_point) the method will throw if `hasTouch` option of the browser context is false.

## text_content

```
def text_content(selector, strict: nil, timeout: nil)
```


Returns `element.textContent`.

## title

```
def title
```


Returns the page's title.

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


Sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text. `page.type` can be used to send
fine-grained keyboard events. To fill values in form fields, use [Page#fill](./page#fill).

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


This method unchecks an element matching `selector` by performing the following steps:
1. Find an element matching `selector`. If there is none, wait until a matching element is attached to the DOM.
1. Ensure that matched element is a checkbox or a radio input. If not, this method throws. If the element is already unchecked, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the matched element, unless `force` option is set. If the element is detached during the checks, the whole action is retried.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Ensure that the element is now unchecked. If not, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

## unroute_all

```
def unroute_all(behavior: nil)
```


Removes all routes created with [Page#route](./page#route) and [Page#route_from_har](./page#route_from_har).

## unroute

```
def unroute(url, handler: nil)
```


Removes a route created with [Page#route](./page#route). When `handler` is not specified, removes all routes for
the `url`.

## url

```
def url
```



## video

```
def video
```


Video object associated with this page.

## viewport_size

```
def viewport_size
```



## expect_console_message

```
def expect_console_message(predicate: nil, timeout: nil, &block)
```


Performs action and waits for a [ConsoleMessage](./console_message) to be logged by in the page. If predicate is provided, it passes
[ConsoleMessage](./console_message) value into the `predicate` function and waits for `predicate(message)` to return a truthy value.
Will throw an error if the page is closed before the [`event: Page.console`] event is fired.

## expect_download

```
def expect_download(predicate: nil, timeout: nil, &block)
```


Performs action and waits for a new [Download](./download). If predicate is provided, it passes
[Download](./download) value into the `predicate` function and waits for `predicate(download)` to return a truthy value.
Will throw an error if the page is closed before the download event is fired.

## expect_event

```
def expect_event(event, predicate: nil, timeout: nil, &block)
```


Waits for event to fire and passes its value into the predicate function. Returns when the predicate returns truthy
value. Will throw an error if the page is closed before the event is fired. Returns the event data value.

**Usage**

```ruby
frame = page.expect_event("framenavigated") do
  page.get_by_role("button")
end
```

## expect_file_chooser

```
def expect_file_chooser(predicate: nil, timeout: nil, &block)
```


Performs action and waits for a new [FileChooser](./file_chooser) to be created. If predicate is provided, it passes
[FileChooser](./file_chooser) value into the `predicate` function and waits for `predicate.call(fileChooser)` to return a truthy value.
Will throw an error if the page is closed before the file chooser is opened.

## wait_for_function

```
def wait_for_function(expression, arg: nil, polling: nil, timeout: nil)
```


Returns when the `expression` returns a truthy value. It resolves to a JSHandle of the truthy value.

**Usage**

The [Page#wait_for_function](./page#wait_for_function) can be used to observe viewport size change:

```ruby
page.evaluate("window.x = 0; setTimeout(() => { window.x = 100 }, 1000);")
page.wait_for_function("() => window.x > 0")
```

To pass an argument to the predicate of [Page#wait_for_function](./page#wait_for_function) function:

```ruby
selector = ".foo"
page.wait_for_function("selector => !!document.querySelector(selector)", arg: selector)
```

## wait_for_load_state

```
def wait_for_load_state(state: nil, timeout: nil)
```


Returns when the required load state has been reached.

This resolves when the page reaches a required load state, `load` by default. The navigation must have been committed
when this method is called. If current document has already reached the required state, resolves immediately.

**NOTE**: Most of the time, this method is not needed because Playwright [auto-waits before every action](https://playwright.dev/python/docs/actionability).

**Usage**

```ruby
page.get_by_role("button").click # click triggers navigation.
page.wait_for_load_state # the promise resolves after "load" event.
```

```ruby
popup = page.expect_popup do
  page.get_by_role("button").click # click triggers a popup.
end

# Wait for the "DOMContentLoaded" event.
popup.wait_for_load_state("domcontentloaded")
puts popup.title # popup is ready to use.
```

## expect_navigation

```
def expect_navigation(timeout: nil, url: nil, waitUntil: nil, &block)
```

:::warning

This method is inherently racy, please use [Page#wait_for_url](./page#wait_for_url) instead.

:::


Waits for the main frame navigation and returns the main resource response. In case of multiple redirects, the navigation
will resolve with the response of the last redirect. In case of navigation to a different anchor or navigation due to
History API usage, the navigation will resolve with `null`.

**Usage**

This resolves when the page navigates to a new URL or reloads. It is useful for when you run code which will indirectly
cause the page to navigate. e.g. The click target has an `onclick` handler that triggers navigation from a `setTimeout`.
Consider this example:

```ruby
page.expect_navigation do
  # This action triggers the navigation after a timeout.
  page.get_by_text("Navigate after timeout").click
end # Resolves after navigation has finished
```

**NOTE**: Usage of the [History API](https://developer.mozilla.org/en-US/docs/Web/API/History_API) to change the URL is considered
a navigation.

## expect_popup

```
def expect_popup(predicate: nil, timeout: nil, &block)
```


Performs action and waits for a popup [Page](./page). If predicate is provided, it passes
[Popup] value into the `predicate` function and waits for `predicate(page)` to return a truthy value.
Will throw an error if the page is closed before the popup event is fired.

## expect_request

```
def expect_request(urlOrPredicate, timeout: nil, &block)
```


Waits for the matching request and returns it. See [waiting for event](https://playwright.dev/python/docs/events#waiting-for-event) for more details about events.

**Usage**

```ruby
page.content = '<form action="https://example.com/resource"><input type="submit" value="trigger request" /></form>'
request = page.expect_request(/example.com\/resource/) do
  page.get_by_text("trigger request").click
end
puts request.headers

page.wait_for_load_state # wait for request finished.

# or with a predicate
page.content = '<form action="https://example.com/resource"><input type="submit" value="trigger request" /></form>'
request = page.expect_request(->(req) { req.url.start_with? 'https://example.com/resource' }) do
  page.get_by_text("trigger request").click
end
puts request.headers
```

## expect_request_finished

```
def expect_request_finished(predicate: nil, timeout: nil, &block)
```


Performs action and waits for a [Request](./request) to finish loading. If predicate is provided, it passes
[Request](./request) value into the `predicate` function and waits for `predicate(request)` to return a truthy value.
Will throw an error if the page is closed before the [`event: Page.requestFinished`] event is fired.

## expect_response

```
def expect_response(urlOrPredicate, timeout: nil, &block)
```


Returns the matched response. See [waiting for event](https://playwright.dev/python/docs/events#waiting-for-event) for more details about events.

**Usage**

```ruby
page.content = '<form action="https://example.com/resource"><input type="submit" value="trigger response" /></form>'
response = page.expect_response(/example.com\/resource/) do
  page.get_by_text("trigger response").click
end
puts response.body
puts response.ok?

page.wait_for_load_state # wait for request finished.

# or with a predicate
page.content = '<form action="https://example.com/resource"><input type="submit" value="trigger response" /></form>'
response = page.expect_response(->(res) { res.url.start_with? 'https://example.com/resource' }) do
  page.get_by_text("trigger response").click
end
puts response.body
puts response.ok?
```

## wait_for_selector

```
def wait_for_selector(selector, state: nil, strict: nil, timeout: nil)
```


Returns when element specified by selector satisfies `state` option. Returns `null` if waiting for `hidden` or
`detached`.

**NOTE**: Playwright automatically waits for element to be ready before performing an action. Using
[Locator](./locator) objects and web-first assertions makes the code wait-for-selector-free.

Wait for the `selector` to satisfy `state` option (either appear/disappear from dom, or become
visible/hidden). If at the moment of calling the method `selector` already satisfies the condition, the method
will return immediately. If the selector doesn't satisfy the condition for the `timeout` milliseconds, the
function will throw.

**Usage**

This method works across navigations:

```ruby
%w[https://playwright.dev/ https://playwright-ruby-client.vercel.app/].each do |current_url|
  page.goto(current_url, waitUntil: "domcontentloaded")
  element = page.wait_for_selector("img")
  puts "Loaded image: #{element["src"]}"
end
```

## wait_for_timeout

```
def wait_for_timeout(timeout)
```


Waits for the given `timeout` in milliseconds.

Note that `page.waitForTimeout()` should only be used for debugging. Tests using the timer in production are going to be
flaky. Use signals such as network events, selectors becoming visible and others instead.

**Usage**

```ruby
page.wait_for_timeout(1000)
```

## wait_for_url

```
def wait_for_url(url, timeout: nil, waitUntil: nil)
```


Waits for the main frame to navigate to the given URL.

**Usage**

```ruby
page.click("a.delayed-navigation") # clicking the link will indirectly cause a navigation
page.wait_for_url("**/target.html")
```

## expect_websocket

```
def expect_websocket(predicate: nil, timeout: nil, &block)
```


Performs action and waits for a new [WebSocket](./web_socket). If predicate is provided, it passes
[WebSocket](./web_socket) value into the `predicate` function and waits for `predicate(webSocket)` to return a truthy value.
Will throw an error if the page is closed before the WebSocket event is fired.

## expect_worker

```
def expect_worker(predicate: nil, timeout: nil, &block)
```


Performs action and waits for a new [Worker](./worker). If predicate is provided, it passes
[Worker](./worker) value into the `predicate` function and waits for `predicate(worker)` to return a truthy value.
Will throw an error if the page is closed before the worker event is fired.

## workers

```
def workers
```


This method returns all of the dedicated [WebWorkers](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API)
associated with the page.

**NOTE**: This does not contain ServiceWorkers

## clock


Playwright has ability to mock clock and passage of time.

## accessibility

## keyboard

## mouse

## request


API testing helper associated with this page. This method returns the same instance as
[BrowserContext#request](./browser_context#request) on the page's context. See [BrowserContext#request](./browser_context#request) for more details.

## touchscreen
