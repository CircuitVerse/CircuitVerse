---
sidebar_position: 10
---

# Locator


Locators are the central piece of Playwright's auto-waiting and retry-ability. In a nutshell, locators represent
a way to find element(s) on the page at any moment. A locator can be created with the [Page#locator](./page#locator) method.

[Learn more about locators](https://playwright.dev/python/docs/locators).

## all

```
def all
```


When the locator points to a list of elements, this returns an array of locators, pointing to their respective elements.

**NOTE**: [Locator#all](./locator#all) does not wait for elements to match the locator, and instead immediately returns whatever is present in the page.

When the list of elements changes dynamically, [Locator#all](./locator#all) will produce unpredictable and flaky results.

When the list of elements is stable, but loaded dynamically, wait for the full list to finish loading before calling [Locator#all](./locator#all).

**Usage**

```ruby
page.get_by_role('listitem').all.each do |li|
  li.click
end
```

## all_inner_texts

```
def all_inner_texts
```


Returns an array of `node.innerText` values for all matching nodes.

**NOTE**: If you need to assert text on the page, prefer [LocatorAssertions#to_have_text](./locator_assertions#to_have_text) with `useInnerText` option to avoid flakiness. See [assertions guide](https://playwright.dev/python/docs/test-assertions) for more details.

**Usage**

```ruby
texts = page.get_by_role("link").all_inner_texts
```

## all_text_contents

```
def all_text_contents
```


Returns an array of `node.textContent` values for all matching nodes.

**NOTE**: If you need to assert text on the page, prefer [LocatorAssertions#to_have_text](./locator_assertions#to_have_text) to avoid flakiness. See [assertions guide](https://playwright.dev/python/docs/test-assertions) for more details.

**Usage**

```ruby
texts = page.get_by_role("link").all_text_contents
```

## and

```
def and(locator)
```


Creates a locator that matches both this locator and the argument locator.

**Usage**

The following example finds a button with a specific title.

```ruby
button = page.get_by_role("button").and(page.get_by_title("Subscribe"))
```

## aria_snapshot

```
def aria_snapshot(timeout: nil)
```


Captures the aria snapshot of the given element.
Read more about [aria snapshots](https://playwright.dev/python/docs/aria-snapshots) and [LocatorAssertions#to_match_aria_snapshot](./locator_assertions#to_match_aria_snapshot) for the corresponding assertion.

**Usage**

```ruby
page.get_by_role("link").aria_snapshot
```

**Details**

This method captures the aria snapshot of the given element. The snapshot is a string that represents the state of the element and its children.
The snapshot can be used to assert the state of the element in the test, or to compare it to state in the future.

The ARIA snapshot is represented using [YAML](https://yaml.org/spec/1.2.2/) markup language:
- The keys of the objects are the roles and optional accessible names of the elements.
- The values are either text content or an array of child elements.
- Generic static text can be represented with the `text` key.

Below is the HTML markup and the respective ARIA snapshot:

```html
<ul aria-label="Links">
  <li><a href="/">Home</a></li>
  <li><a href="/about">About</a></li>
<ul>
```

```yml
- list "Links":
  - listitem:
    - link "Home"
  - listitem:
    - link "About"
```

## blur

```
def blur(timeout: nil)
```


Calls [blur](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/blur) on the element.

## bounding_box

```
def bounding_box(timeout: nil)
```


This method returns the bounding box of the element matching the locator, or `null` if the element is not visible. The bounding box is
calculated relative to the main frame viewport - which is usually the same as the browser window.

**Details**

Scrolling affects the returned bounding box, similarly to
[Element.getBoundingClientRect](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect). That
means `x` and/or `y` may be negative.

Elements from child frames return the bounding box relative to the main frame, unlike the
[Element.getBoundingClientRect](https://developer.mozilla.org/en-US/docs/Web/API/Element/getBoundingClientRect).

Assuming the page is static, it is safe to use bounding box coordinates to perform input. For example, the following
snippet should click the center of the element.

**Usage**

```ruby
element = page.get_by_role("button")
box = element.bounding_box
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


Ensure that checkbox or radio element is checked.

**Details**

Performs the following steps:
1. Ensure that element is a checkbox or a radio input. If not, this method throws. If the element is already checked, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Ensure that the element is now checked. If not, this method throws.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

**Usage**

```ruby
page.get_by_role("checkbox").check
```

## clear

```
def clear(force: nil, noWaitAfter: nil, timeout: nil)
```


Clear the input field.

**Details**

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, focuses the element, clears it and triggers an `input` event after clearing.

If the target element is not an `<input>`, `<textarea>` or `[contenteditable]` element, this method throws an error. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be cleared instead.

**Usage**

```ruby
page.get_by_role("textbox").clear
```

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


Click an element.

**Details**

This method clicks the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element, or the specified `position`.
1. Wait for initiated navigations to either succeed or fail, unless `noWaitAfter` option is set.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

**Usage**

Click a button:

```ruby
page.get_by_role("button").click
```

Shift-right-click at a specific position on a canvas:

```ruby
page.locator("canvas").click(button: "right", modifiers: ["Shift"], position: { x: 23, y: 32 })
```

## count

```
def count
```


Returns the number of elements matching the locator.

**NOTE**: If you need to assert the number of elements on the page, prefer [LocatorAssertions#to_have_count](./locator_assertions#to_have_count) to avoid flakiness. See [assertions guide](https://playwright.dev/python/docs/test-assertions) for more details.

**Usage**

```ruby
count = page.get_by_role("listitem").count
```

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


Double-click an element.

**Details**

This method double clicks the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to double click in the center of the element, or the specified `position`.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

**NOTE**: `element.dblclick()` dispatches two `click` events and a single `dblclick` event.

## describe

```
def describe(description)
```


Describes the locator, description is used in the trace viewer and reports.
Returns the locator pointing to the same element.

**Usage**

```ruby
button = page.get_by_test_id("btn-sub").describe("Subscribe button")
button.click
```

## dispatch_event

```
def dispatch_event(type, eventInit: nil, timeout: nil)
```


Programmatically dispatch an event on the matching element.

**Usage**

```ruby
locator.dispatch_event("click")
```

**Details**

The snippet above dispatches the `click` event on the element. Regardless of the visibility state of the element, `click`
is dispatched. This is equivalent to calling
[element.click()](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/click).

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
locator.dispatch_event("dragstart", eventInit: { dataTransfer: data_transfer })
```

## drag_to

```
def drag_to(
      target,
      force: nil,
      noWaitAfter: nil,
      sourcePosition: nil,
      targetPosition: nil,
      timeout: nil,
      trial: nil)
```


Drag the source element towards the target element and drop it.

**Details**

This method drags the locator to another target locator or target position. It will
first move to the source element, perform a `mousedown`, then move to the target
element or position and perform a `mouseup`.

**Usage**

```ruby
source = page.locator("#source")
target = page.locator("#target")

source.drag_to(target)
# or specify exact positions relative to the top-left corners of the elements:
source.drag_to(
  target,
  sourcePosition: { x: 34, y: 7 },
  targetPosition: { x: 10, y: 20 },
)
```

## element_handle

```
def element_handle(timeout: nil)
```


Resolves given locator to the first matching DOM element. If there are no matching elements, waits for one. If multiple elements match the locator, throws.

## element_handles

```
def element_handles
```


Resolves given locator to all matching DOM elements. If there are no matching elements, returns an empty list.

## content_frame

```
def content_frame
```


Returns a [FrameLocator](./frame_locator) object pointing to the same `iframe` as this locator.

Useful when you have a [Locator](./locator) object obtained somewhere, and later on would like to interact with the content inside the frame.

For a reverse operation, use [FrameLocator#owner](./frame_locator#owner).

**Usage**

```ruby
locator = page.locator('iframe[name="embedded"]')
# ...
frame_locator = locator.content_frame
frame_locator.get_by_role("button").click
```

## evaluate

```
def evaluate(expression, arg: nil, timeout: nil)
```


Execute JavaScript code in the page, taking the matching element as an argument.

**Details**

Returns the return value of `expression`, called with the matching element as a first argument, and `arg` as a second argument.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), this method will wait for the promise to resolve and return its value.

If `expression` throws or rejects, this method throws.

**Usage**

Passing argument to `expression`:

```ruby
page.get_by_test_id("myId").evaluate("(element, [x, y]) => element.textContent + ' ' + x * y", arg: [7, 8]) # => "myId text 56"
```

## evaluate_all

```
def evaluate_all(expression, arg: nil)
```


Execute JavaScript code in the page, taking all matching elements as an argument.

**Details**

Returns the return value of `expression`, called with an array of all matching elements as a first argument, and `arg` as a second argument.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), this method will wait for the promise to resolve and return its value.

If `expression` throws or rejects, this method throws.

**Usage**

```ruby
locator = page.locator("div")
more_than_ten = locator.evaluate_all("(divs, min) => divs.length >= min", arg: 10)
```

## evaluate_handle

```
def evaluate_handle(expression, arg: nil, timeout: nil)
```


Execute JavaScript code in the page, taking the matching element as an argument, and return a [JSHandle](./js_handle) with the result.

**Details**

Returns the return value of `expression` as a[JSHandle](./js_handle), called with the matching element as a first argument, and `arg` as a second argument.

The only difference between [Locator#evaluate](./locator#evaluate) and [Locator#evaluate_handle](./locator#evaluate_handle) is that [Locator#evaluate_handle](./locator#evaluate_handle) returns [JSHandle](./js_handle).

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), this method will wait for the promise to resolve and return its value.

If `expression` throws or rejects, this method throws.

See [Page#evaluate_handle](./page#evaluate_handle) for more details.

## fill

```
def fill(value, force: nil, noWaitAfter: nil, timeout: nil)
```


Set a value to the input field.

**Usage**

```ruby
page.get_by_role("textbox").fill("example value")
```

**Details**

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, focuses the element, fills it and triggers an `input` event after filling. Note that you can pass an empty string to clear the input field.

If the target element is not an `<input>`, `<textarea>` or `[contenteditable]` element, this method throws an error. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be filled instead.

To send fine-grained keyboard events, use [Locator#press_sequentially](./locator#press_sequentially).

## filter

```
def filter(
      has: nil,
      hasNot: nil,
      hasNotText: nil,
      hasText: nil,
      visible: nil)
```


This method narrows existing locator according to the options, for example filters by text.
It can be chained to filter multiple times.

**Usage**

```ruby
row_locator = page.locator("tr")
# ...
row_locator.
    filter(hasText: "text in column 1").
    filter(has: page.get_by_role("button", name: "column 2 button")).
    screenshot
```

## first

```
def first
```


Returns locator to the first matching element.

## focus

```
def focus(timeout: nil)
```


Calls [focus](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/focus) on the matching element.

## frame_locator

```
def frame_locator(selector)
```


When working with iframes, you can create a frame locator that will enter the iframe and allow locating elements
in that iframe:

**Usage**

```ruby
locator = page.frame_locator("iframe").get_by_text("Submit")
locator.click
```

## get_attribute

```
def get_attribute(name, timeout: nil)
```
alias: `[]`


Returns the matching element's attribute value.

**NOTE**: If you need to assert an element's attribute, prefer [LocatorAssertions#to_have_attribute](./locator_assertions#to_have_attribute) to avoid flakiness. See [assertions guide](https://playwright.dev/python/docs/test-assertions) for more details.

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

## highlight

```
def highlight
```


Highlight the corresponding element(s) on the screen. Useful for debugging, don't commit the code that uses [Locator#highlight](./locator#highlight).

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


Hover over the matching element.

**Usage**

```ruby
page.get_by_role("link").hover
```

**Details**

This method hovers over the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to hover over the center of the element, or the specified `position`.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

## inner_html

```
def inner_html(timeout: nil)
```


Returns the [`element.innerHTML`](https://developer.mozilla.org/en-US/docs/Web/API/Element/innerHTML).

## inner_text

```
def inner_text(timeout: nil)
```


Returns the [`element.innerText`](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/innerText).

**NOTE**: If you need to assert text on the page, prefer [LocatorAssertions#to_have_text](./locator_assertions#to_have_text) with `useInnerText` option to avoid flakiness. See [assertions guide](https://playwright.dev/python/docs/test-assertions) for more details.

## input_value

```
def input_value(timeout: nil)
```


Returns the value for the matching `<input>` or `<textarea>` or `<select>` element.

**NOTE**: If you need to assert input value, prefer [LocatorAssertions#to_have_value](./locator_assertions#to_have_value) to avoid flakiness. See [assertions guide](https://playwright.dev/python/docs/test-assertions) for more details.

**Usage**

```ruby
value = page.get_by_role("textbox").input_value
```

**Details**

Throws elements that are not an input, textarea or a select. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), returns the value of the control.

## checked?

```
def checked?(timeout: nil)
```


Returns whether the element is checked. Throws if the element is not a checkbox or radio input.

**NOTE**: If you need to assert that checkbox is checked, prefer [LocatorAssertions#to_be_checked](./locator_assertions#to_be_checked) to avoid flakiness. See [assertions guide](https://playwright.dev/python/docs/test-assertions) for more details.

**Usage**

```ruby
checked = page.get_by_role("checkbox").checked?
```

## disabled?

```
def disabled?(timeout: nil)
```


Returns whether the element is disabled, the opposite of [enabled](https://playwright.dev/python/docs/actionability#enabled).

**NOTE**: If you need to assert that an element is disabled, prefer [LocatorAssertions#to_be_disabled](./locator_assertions#to_be_disabled) to avoid flakiness. See [assertions guide](https://playwright.dev/python/docs/test-assertions) for more details.

**Usage**

```ruby
disabled = page.get_by_role("button").disabled?
```

## editable?

```
def editable?(timeout: nil)
```


Returns whether the element is [editable](https://playwright.dev/python/docs/actionability#editable). If the target element is not an `<input>`, `<textarea>`, `<select>`, `[contenteditable]` and does not have a role allowing `[aria-readonly]`, this method throws an error.

**NOTE**: If you need to assert that an element is editable, prefer [LocatorAssertions#to_be_editable](./locator_assertions#to_be_editable) to avoid flakiness. See [assertions guide](https://playwright.dev/python/docs/test-assertions) for more details.

**Usage**

```ruby
editable = page.get_by_role("textbox").editable?
```

## enabled?

```
def enabled?(timeout: nil)
```


Returns whether the element is [enabled](https://playwright.dev/python/docs/actionability#enabled).

**NOTE**: If you need to assert that an element is enabled, prefer [LocatorAssertions#to_be_enabled](./locator_assertions#to_be_enabled) to avoid flakiness. See [assertions guide](https://playwright.dev/python/docs/test-assertions) for more details.

**Usage**

```ruby
enabled = page.get_by_role("button").enabled?
```

## hidden?

```
def hidden?(timeout: nil)
```


Returns whether the element is hidden, the opposite of [visible](https://playwright.dev/python/docs/actionability#visible).

**NOTE**: If you need to assert that element is hidden, prefer [LocatorAssertions#to_be_hidden](./locator_assertions#to_be_hidden) to avoid flakiness. See [assertions guide](https://playwright.dev/python/docs/test-assertions) for more details.

**Usage**

```ruby
hidden = page.get_by_role("button").hidden?
```

## visible?

```
def visible?(timeout: nil)
```


Returns whether the element is [visible](https://playwright.dev/python/docs/actionability#visible).

**NOTE**: If you need to assert that element is visible, prefer [LocatorAssertions#to_be_visible](./locator_assertions#to_be_visible) to avoid flakiness. See [assertions guide](https://playwright.dev/python/docs/test-assertions) for more details.

**Usage**

```ruby
visible = page.get_by_role("button").visible?
```

## last

```
def last
```


Returns locator to the last matching element.

**Usage**

```ruby
banana = page.get_by_role("listitem").last
```

## locator

```
def locator(
      selectorOrLocator,
      has: nil,
      hasNot: nil,
      hasNotText: nil,
      hasText: nil)
```


The method finds an element matching the specified selector in the locator's subtree. It also accepts filter options, similar to [Locator#filter](./locator#filter) method.

[Learn more about locators](https://playwright.dev/python/docs/locators).

## nth

```
def nth(index)
```


Returns locator to the n-th matching element. It's zero based, `nth(0)` selects the first element.

**Usage**

```ruby
banana = page.get_by_role("listitem").nth(2)
```

## or

```
def or(locator)
```


Creates a locator matching all elements that match one or both of the two locators.

Note that when both locators match something, the resulting locator will have multiple matches, potentially causing a [locator strictness](https://playwright.dev/python/docs/locators#strictness) violation.

**Usage**

Consider a scenario where you'd like to click on a "New email" button, but sometimes a security settings dialog shows up instead. In this case, you can wait for either a "New email" button, or a dialog and act accordingly.

**NOTE**: If both "New email" button and security dialog appear on screen, the "or" locator will match both of them,
possibly throwing the ["strict mode violation" error](https://playwright.dev/python/docs/locators#strictness). In this case, you can use [Locator#first](./locator#first) to only match one of them.

```ruby
new_email = page.get_by_role("button", name: "New")
dialog = page.get_by_text("Confirm security settings")
new_email.or(dialog).first.wait_for(state: 'visible')
if dialog.visible?
  page.get_by_role("button", name: "Dismiss").click
end
new_email.click
```

## page

```
def page
```


A page this locator belongs to.

## press

```
def press(key, delay: nil, noWaitAfter: nil, timeout: nil)
```


Focuses the matching element and presses a combination of the keys.

**Usage**

```ruby
page.get_by_role("textbox").press("Backspace")
```

**Details**

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

## press_sequentially

```
def press_sequentially(text, delay: nil, noWaitAfter: nil, timeout: nil)
```


**NOTE**: In most cases, you should use [Locator#fill](./locator#fill) instead. You only need to press keys one by one if there is special keyboard handling on the page.

Focuses the element, and then sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text.

To press a special key, like `Control` or `ArrowDown`, use [Locator#press](./locator#press).

**Usage**

```ruby
element.press_sequentially("hello") # types instantly
element.press_sequentially("world", delay: 100) # types slower, like a user
```

An example of typing into a text field and then submitting the form:

```ruby
element = page.get_by_label("Password")
element.press_sequentially("my password")
element.press("Enter")
```

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


Take a screenshot of the element matching the locator.

**Usage**

```ruby
page.get_by_role("link").screenshot
```

Disable animations and save screenshot to a file:

```ruby
page.get_by_role("link").screenshot(animations="disabled", path="link.png")
```

**Details**

This method captures a screenshot of the page, clipped to the size and position of a particular element matching the locator. If the element is covered by other elements, it will not be actually visible on the screenshot. If the element is a scrollable container, only the currently scrolled content will be visible on the screenshot.

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


Selects option or options in `<select>`.

**Details**

This method waits for [actionability](https://playwright.dev/python/docs/actionability) checks, waits until all specified options are present in the `<select>` element and selects these options.

If the target element is not a `<select>` element, this method throws an error. However, if the element is inside the `<label>` element that has an associated [control](https://developer.mozilla.org/en-US/docs/Web/API/HTMLLabelElement/control), the control will be used instead.

Returns the array of option values that have been successfully selected.

Triggers a `change` and `input` event once all the provided options have been selected.

**Usage**

```html
<select multiple>
  <option value="red">Red</option>
  <option value="green">Green</option>
  <option value="blue">Blue</option>
</select>
```

```ruby
# single selection matching the value or label
element.select_option(value: "blue")
# single selection matching both the label
element.select_option(label: "blue")
# multiple selection
element.select_option(value: ["red", "green", "blue"])
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


Set the state of a checkbox or a radio element.

**Usage**

```ruby
page.get_by_role("checkbox").checked = true
page.get_by_role("checkbox").set_checked(true)
```

**Details**

This method checks or unchecks an element by performing the following steps:
1. Ensure that matched element is a checkbox or a radio input. If not, this method throws.
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


Upload file or multiple files into `<input type=file>`.
For inputs with a `[webkitdirectory]` attribute, only a single directory path is supported.

**Usage**

```ruby
# Select one file
page.get_by_label("Upload file").set_input_files('myfile.pdf')

# Select multiple files
page.get_by_label("Upload files").set_input_files(['file1.txt', 'file2.txt'])

# Select a directory
page.get_by_label("Upload directory").set_input_files('mydir')

# Remove all the selected files
page.get_by_label("Upload file").set_input_files([])
```

**Details**

Sets the value of the file input to these file paths or files. If some of the `filePaths` are relative paths, then they
are resolved relative to the current working directory. For empty array, clears the selected files.

This method expects [Locator](./locator) to point to an
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


Perform a tap gesture on the element matching the locator. For examples of emulating other gestures by manually dispatching touch events, see the [emulating legacy touch events](https://playwright.dev/python/docs/touch-events) page.

**Details**

This method taps the element by performing the following steps:
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#touchscreen](./page#touchscreen) to tap the center of the element, or the specified `position`.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

**NOTE**: `element.tap()` requires that the `hasTouch` option of the browser context be set to true.

## text_content

```
def text_content(timeout: nil)
```


Returns the [`node.textContent`](https://developer.mozilla.org/en-US/docs/Web/API/Node/textContent).

**NOTE**: If you need to assert text on the page, prefer [LocatorAssertions#to_have_text](./locator_assertions#to_have_text) to avoid flakiness. See [assertions guide](https://playwright.dev/python/docs/test-assertions) for more details.

## type

```
def type(text, delay: nil, noWaitAfter: nil, timeout: nil)
```

:::warning

In most cases, you should use [Locator#fill](./locator#fill) instead. You only need to press keys one by one if there is special keyboard handling on the page - in this case use [Locator#press_sequentially](./locator#press_sequentially).

:::


Focuses the element, and then sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text.

To press a special key, like `Control` or `ArrowDown`, use [Locator#press](./locator#press).

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


Ensure that checkbox or radio element is unchecked.

**Usage**

```ruby
page.get_by_role("checkbox").uncheck
```

**Details**

This method unchecks the element by performing the following steps:
1. Ensure that element is a checkbox or a radio input. If not, this method throws. If the element is already unchecked, this method returns immediately.
1. Wait for [actionability](https://playwright.dev/python/docs/actionability) checks on the element, unless `force` option is set.
1. Scroll the element into view if needed.
1. Use [Page#mouse](./page#mouse) to click in the center of the element.
1. Ensure that the element is now unchecked. If not, this method throws.

If the element is detached from the DOM at any moment during the action, this method throws.

When all steps combined have not finished during the specified `timeout`, this method throws a
`TimeoutError`. Passing zero timeout disables this.

## wait_for

```
def wait_for(state: nil, timeout: nil)
```


Returns when element specified by locator satisfies the `state` option.

If target element already satisfies the condition, the method returns immediately. Otherwise, waits for up to
`timeout` milliseconds until the condition is met.

**Usage**

```ruby
order_sent = page.locator("#order-sent")
order_sent.wait_for
```
