---
sidebar_position: 10
---

# FrameLocator


FrameLocator represents a view to the `iframe` on the page. It captures the logic sufficient to retrieve the `iframe` and locate elements in that iframe. FrameLocator can be created with either [Locator#content_frame](./locator#content_frame), [Page#frame_locator](./page#frame_locator) or [Locator#frame_locator](./locator#frame_locator) method.

```ruby
locator = page.locator("my-frame").content_frame.get_by_text("Submit")
locator.click
```

**Strictness**

Frame locators are strict. This means that all operations on frame locators will throw if more than one element matches a given selector.

```ruby
# Throws if there are several frames in DOM:
page.locator('.result-frame').content_frame.get_by_role('button').click

# Works because we explicitly tell locator to pick the first frame:
page.locator('.result-frame').first.content_frame.get_by_role('button').click
```

**Converting Locator to FrameLocator**

If you have a [Locator](./locator) object pointing to an `iframe` it can be converted to [FrameLocator](./frame_locator) using [Locator#content_frame](./locator#content_frame).

**Converting FrameLocator to Locator**

If you have a [FrameLocator](./frame_locator) object it can be converted to [Locator](./locator) pointing to the same `iframe` using [FrameLocator#owner](./frame_locator#owner).

## first

```
def first
```

:::warning

Use [Locator#first](./locator#first) followed by [Locator#content_frame](./locator#content_frame) instead.

:::


Returns locator to the first matching frame.

## frame_locator

```
def frame_locator(selector)
```


When working with iframes, you can create a frame locator that will enter the iframe and allow selecting elements
in that iframe.

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

## last

```
def last
```

:::warning

Use [Locator#last](./locator#last) followed by [Locator#content_frame](./locator#content_frame) instead.

:::


Returns locator to the last matching frame.

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

:::warning

Use [Locator#nth](./locator#nth) followed by [Locator#content_frame](./locator#content_frame) instead.

:::


Returns locator to the n-th matching frame. It's zero based, `nth(0)` selects the first frame.

## owner

```
def owner
```


Returns a [Locator](./locator) object pointing to the same `iframe` as this frame locator.

Useful when you have a [FrameLocator](./frame_locator) object obtained somewhere, and later on would like to interact with the `iframe` element.

For a reverse operation, use [Locator#content_frame](./locator#content_frame).

**Usage**

```ruby
frame_locator = page.locator('iframe[name="embedded"]').content_frame
# ...
locator = frame_locator.owner
locator.get_attribute('src') # => frame1.html
```
