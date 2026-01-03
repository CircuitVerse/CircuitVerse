---
sidebar_position: 10
---

# LocatorAssertions


The LocatorAssertions class provides assertion methods for RSpec like `expect(locator).to have_text("Something")`. Note that we have to explicitly include `playwright/test` and `Playwright::Test::Matchers` for using RSpec matchers.

```ruby
require 'playwright/test'

describe 'your system testing' do
  include Playwright::Test::Matchers
```

Since the matcher comes with auto-waiting feature, we don't have to describe trivial codes waiting for elements any more :)

```ruby
page.content = <<~HTML
<div id="my_status" class="status">Pending</div>
<button onClick="setTimeout(() => { document.getElementById('my_status').innerText='Something Submitted!!' }, 2000)">Click me</button>
HTML

page.get_by_role("button").click
expect(page.locator(".status")).to have_text("Submitted") # auto-waiting
```

## not_to_be_attached

```ruby
expect(locator).not_to be_attached(attached: nil, timeout: nil)
```


The opposite of [LocatorAssertions#to_be_attached](./locator_assertions#to_be_attached).

## not_to_be_checked

```ruby
expect(locator).not_to be_checked(timeout: nil)
```


The opposite of [LocatorAssertions#to_be_checked](./locator_assertions#to_be_checked).

## not_to_be_disabled

```ruby
expect(locator).not_to be_disabled(timeout: nil)
```


The opposite of [LocatorAssertions#to_be_disabled](./locator_assertions#to_be_disabled).

## not_to_be_editable

```ruby
expect(locator).not_to be_editable(editable: nil, timeout: nil)
```


The opposite of [LocatorAssertions#to_be_editable](./locator_assertions#to_be_editable).

## not_to_be_empty

```ruby
expect(locator).not_to be_empty(timeout: nil)
```


The opposite of [LocatorAssertions#to_be_empty](./locator_assertions#to_be_empty).

## not_to_be_enabled

```ruby
expect(locator).not_to be_enabled(enabled: nil, timeout: nil)
```


The opposite of [LocatorAssertions#to_be_enabled](./locator_assertions#to_be_enabled).

## not_to_be_focused

```ruby
expect(locator).not_to be_focused(timeout: nil)
```


The opposite of [LocatorAssertions#to_be_focused](./locator_assertions#to_be_focused).

## not_to_be_hidden

```ruby
expect(locator).not_to be_hidden(timeout: nil)
```


The opposite of [LocatorAssertions#to_be_hidden](./locator_assertions#to_be_hidden).

## not_to_be_in_viewport

```ruby
expect(locator).not_to be_in_viewport(ratio: nil, timeout: nil)
```


The opposite of [LocatorAssertions#to_be_in_viewport](./locator_assertions#to_be_in_viewport).

## not_to_be_visible

```ruby
expect(locator).not_to be_visible(timeout: nil, visible: nil)
```


The opposite of [LocatorAssertions#to_be_visible](./locator_assertions#to_be_visible).

## not_to_contain_class

```ruby
expect(locator).not_to contain_class(expected, timeout: nil)
```


The opposite of [LocatorAssertions#to_contain_class](./locator_assertions#to_contain_class).

## not_to_contain_text

```ruby
expect(locator).not_to contain_text(expected, ignoreCase: nil, timeout: nil, useInnerText: nil)
```


The opposite of [LocatorAssertions#to_contain_text](./locator_assertions#to_contain_text).

## not_to_have_accessible_description

```ruby
expect(locator).not_to have_accessible_description(name, ignoreCase: nil, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_accessible_description](./locator_assertions#to_have_accessible_description).

## not_to_have_accessible_error_message

```ruby
expect(locator).not_to have_accessible_error_message(errorMessage, ignoreCase: nil, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_accessible_error_message](./locator_assertions#to_have_accessible_error_message).

## not_to_have_accessible_name

```ruby
expect(locator).not_to have_accessible_name(name, ignoreCase: nil, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_accessible_name](./locator_assertions#to_have_accessible_name).

## not_to_have_attribute

```ruby
expect(locator).not_to have_attribute(name, value, ignoreCase: nil, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_attribute](./locator_assertions#to_have_attribute).

## not_to_have_class

```ruby
expect(locator).not_to have_class(expected, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_class](./locator_assertions#to_have_class).

## not_to_have_count

```ruby
expect(locator).not_to have_count(count, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_count](./locator_assertions#to_have_count).

## not_to_have_css

```ruby
expect(locator).not_to have_css(name, value, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_css](./locator_assertions#to_have_css).

## not_to_have_id

```ruby
expect(locator).not_to have_id(id, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_id](./locator_assertions#to_have_id).

## not_to_have_js_property

```ruby
expect(locator).not_to have_js_property(name, value, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_js_property](./locator_assertions#to_have_js_property).

## not_to_have_role

```ruby
expect(locator).not_to have_role(role, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_role](./locator_assertions#to_have_role).

## not_to_have_text

```ruby
expect(locator).not_to have_text(expected, ignoreCase: nil, timeout: nil, useInnerText: nil)
```


The opposite of [LocatorAssertions#to_have_text](./locator_assertions#to_have_text).

## not_to_have_value

```ruby
expect(locator).not_to have_value(value, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_value](./locator_assertions#to_have_value).

## not_to_have_values

```ruby
expect(locator).not_to have_values(values, timeout: nil)
```


The opposite of [LocatorAssertions#to_have_values](./locator_assertions#to_have_values).

## not_to_match_aria_snapshot

```ruby
expect(locator).not_to match_aria_snapshot(expected, timeout: nil)
```


The opposite of [LocatorAssertions#to_match_aria_snapshot](./locator_assertions#to_match_aria_snapshot).

## to_be_attached

```ruby
expect(locator).to be_attached(attached: nil, timeout: nil)
```


Ensures that [Locator](./locator) points to an element that is [connected](https://developer.mozilla.org/en-US/docs/Web/API/Node/isConnected) to a Document or a ShadowRoot.

**Usage**

```ruby
page.content = <<~HTML
<div id="hidden_status" style="display: none">Pending</div>
<button onClick="document.getElementById('hidden_status').innerText='Hidden text'">Click me</button>
HTML

page.get_by_role("button").click
expect(page.get_by_text("Hidden text")).to be_attached
```

## to_be_checked

```ruby
expect(locator).to be_checked(checked: nil, indeterminate: nil, timeout: nil)
```


Ensures the [Locator](./locator) points to a checked input.

**Usage**

```ruby
locator = page.get_by_label("Subscribe to newsletter")
expect(locator).to be_checked
```

## to_be_disabled

```ruby
expect(locator).to be_disabled(timeout: nil)
```


Ensures the [Locator](./locator) points to a disabled element. Element is disabled if it has "disabled" attribute
or is disabled via ['aria-disabled'](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-disabled).
Note that only native control elements such as HTML `button`, `input`, `select`, `textarea`, `option`, `optgroup`
can be disabled by setting "disabled" attribute. "disabled" attribute on other elements is ignored
by the browser.

**Usage**

```ruby
locator = page.locator("button.submit")
locator.click
expect(locator).to be_disabled
```

## to_be_editable

```ruby
expect(locator).to be_editable(editable: nil, timeout: nil)
```


Ensures the [Locator](./locator) points to an editable element.

**Usage**

```ruby
locator = page.get_by_role("textbox")
expect(locator).to be_editable
```

## to_be_empty

```ruby
expect(locator).to be_empty(timeout: nil)
```


Ensures the [Locator](./locator) points to an empty editable element or to a DOM node that has no text.

**Usage**

```ruby
locator = page.locator("div.warning")
expect(locator).to be_empty
```

## to_be_enabled

```ruby
expect(locator).to be_enabled(enabled: nil, timeout: nil)
```


Ensures the [Locator](./locator) points to an enabled element.

**Usage**

```ruby
locator = page.locator("button.submit")
expect(locator).to be_enabled
```

## to_be_focused

```ruby
expect(locator).to be_focused(timeout: nil)
```


Ensures the [Locator](./locator) points to a focused DOM node.

**Usage**

```ruby
locator = page.get_by_role("textbox")
expect(locator).to be_focused
```

## to_be_hidden

```ruby
expect(locator).to be_hidden(timeout: nil)
```


Ensures that [Locator](./locator) either does not resolve to any DOM node, or resolves to a [non-visible](https://playwright.dev/python/docs/actionability#visible) one.

**Usage**

```ruby
locator = page.locator(".my-element")
expect(locator).to be_hidden
```

## to_be_in_viewport

```ruby
expect(locator).to be_in_viewport(ratio: nil, timeout: nil)
```


Ensures the [Locator](./locator) points to an element that intersects viewport, according to the [intersection observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API).

**Usage**

```ruby
locator = page.get_by_role("button")
# Make sure at least some part of element intersects viewport.
expect(locator).to be_in_viewport
# Make sure element is fully outside of viewport.
expect(locator).not_to be_in_viewport
# Make sure that at least half of the element intersects viewport.
expect(locator).to be_in_viewport(ratio: 0.5)
```

## to_be_visible

```ruby
expect(locator).to be_visible(timeout: nil, visible: nil)
```


Ensures that [Locator](./locator) points to an attached and [visible](https://playwright.dev/python/docs/actionability#visible) DOM node.

To check that at least one element from the list is visible, use [Locator#first](./locator#first).

**Usage**

```ruby
# A specific element is visible.
expect(page.get_by_text("Welcome")).to be_visible

# At least one item in the list is visible.
expect(page.get_by_test_id("todo-item").first).to be_visible

# At least one of the two elements is visible, possibly both.
expect(
  page.get_by_role('button', name: 'Sign in').or(page.get_by_role('button', name: 'Sign up')).first
).to be_visible
```

## to_contain_class

```ruby
expect(locator).to contain_class(expected, timeout: nil)
```


Ensures the [Locator](./locator) points to an element with given CSS classes. All classes from the asserted value, separated by spaces, must be present in the [Element.classList](https://developer.mozilla.org/en-US/docs/Web/API/Element/classList) in any order.

**Usage**

```html
<div class='middle selected row' id='component'></div>
```

```ruby
locator = page.locator("#component")
expect(locator).to contain_class("middle selected row")
expect(locator).to contain_class("selected")
expect(locator).to contain_class("row middle")
```

When an array is passed, the method asserts that the list of elements located matches the corresponding list of expected class lists. Each element's class attribute is matched against the corresponding class in the array:

```html
<div class='list'>
  <div class='component inactive'></div>
  <div class='component active'></div>
  <div class='component inactive'></div>
</div>
```

```ruby
locator = page.locator(".list > .component")
expect(locator).to contain_class(["inactive", "active", "inactive"])
```

## to_contain_text

```ruby
expect(locator).to contain_text(expected, ignoreCase: nil, timeout: nil, useInnerText: nil)
```


Ensures the [Locator](./locator) points to an element that contains the given text. All nested elements will be considered when computing the text content of the element. You can use regular expressions for the value as well.

**Details**

When `expected` parameter is a string, Playwright will normalize whitespaces and line breaks both in the actual text and
in the expected string before matching. When regular expression is used, the actual text is matched as is.

**Usage**

```ruby
locator = page.locator('.title')
expect(locator).to contain_text("substring")
expect(locator).to contain_text(/\d messages/)
```

If you pass an array as an expected value, the expectations are:
1. Locator resolves to a list of elements.
1. Elements from a **subset** of this list contain text from the expected array, respectively.
1. The matching subset of elements has the same order as the expected array.
1. Each text value from the expected array is matched by some element from the list.

For example, consider the following list:

```html
<ul>
  <li>Item Text 1</li>
  <li>Item Text 2</li>
  <li>Item Text 3</li>
</ul>
```

Let's see how we can use the assertion:

```ruby
# ✓ Contains the right items in the right order
expect(page.locator("ul > li")).to contain_text(["Text 1", "Text 3", "Text 4"])

# ✖ Wrong order
expect(page.locator("ul > li")).to contain_text(["Text 3", "Text 2"])

# ✖ No item contains this text
expect(page.locator("ul > li")).to contain_text(["Some 33"])

# ✖ Locator points to the outer list element, not to the list items
expect(page.locator("ul")).to contain_text(["Text 3"])
```

## to_have_accessible_description

```ruby
expect(locator).to have_accessible_description(description, ignoreCase: nil, timeout: nil)
```


Ensures the [Locator](./locator) points to an element with a given [accessible description](https://w3c.github.io/accname/#dfn-accessible-description).

**Usage**

```ruby
locator = page.get_by_test_id("save-button")
expect(locator).to have_accessible_description("Save results to disk")
```

## to_have_accessible_error_message

```ruby
expect(locator).to have_accessible_error_message(errorMessage, ignoreCase: nil, timeout: nil)
```


Ensures the [Locator](./locator) points to an element with a given [aria errormessage](https://w3c.github.io/aria/#aria-errormessage).

**Usage**

```ruby
locator = page.get_by_test_id("username-input")
expect(locator).to have_accessible_error_message("Username is required.")
```

## to_have_accessible_name

```ruby
expect(locator).to have_accessible_name(name, ignoreCase: nil, timeout: nil)
```


Ensures the [Locator](./locator) points to an element with a given [accessible name](https://w3c.github.io/accname/#dfn-accessible-name).

**Usage**

```ruby
locator = page.get_by_test_id("save-button")
expect(locator).to have_accessible_name("Save to disk")
```

## to_have_attribute

```ruby
expect(locator).to have_attribute(name, value, ignoreCase: nil, timeout: nil)
```


Ensures the [Locator](./locator) points to an element with given attribute.

**Usage**

```ruby
locator = page.locator("input")
expect(locator).to have_attribute("type", "text")
```

## to_have_class

```ruby
expect(locator).to have_class(expected, timeout: nil)
```


Ensures the [Locator](./locator) points to an element with given CSS classes. When a string is provided, it must fully match the element's `class` attribute. To match individual classes use [LocatorAssertions#to_contain_class](./locator_assertions#to_contain_class).

**Usage**

```html
<div class='middle selected row' id='component'></div>
```

```ruby
locator = page.locator("#component")
expect(locator).to have_class(/(^|\s)selected(\s|$)/)
expect(locator).to have_class("middle selected row")
```

When an array is passed, the method asserts that the list of elements located matches the corresponding list of expected class values. Each element's class attribute is matched against the corresponding string or regular expression in the array:

```ruby
locator = page.locator("list > .component")
expect(locator).to have_class(["component", "component selected", "component"])
```

## to_have_count

```ruby
expect(locator).to have_count(count, timeout: nil)
```


Ensures the [Locator](./locator) resolves to an exact number of DOM nodes.

**Usage**

```ruby
locator = page.locator("list > .component")
expect(locator).to have_count(3)
```

## to_have_css

```ruby
expect(locator).to have_css(name, value, timeout: nil)
```


Ensures the [Locator](./locator) resolves to an element with the given computed CSS style.

**Usage**

```ruby
locator = page.get_by_role("button")
expect(locator).to have_css("display", "flex")
```

## to_have_id

```ruby
expect(locator).to have_id(id, timeout: nil)
```


Ensures the [Locator](./locator) points to an element with the given DOM Node ID.

**Usage**

```ruby
locator = page.get_by_role("textbox")
expect(locator).to have_id("lastname")
```

## to_have_js_property

```ruby
expect(locator).to have_js_property(name, value, timeout: nil)
```


Ensures the [Locator](./locator) points to an element with given JavaScript property. Note that this property can be
of a primitive type as well as a plain serializable JavaScript object.

**Usage**

```ruby
locator = page.locator(".component")
expect(locator).to have_js_property("loaded", true)
```

## to_have_role

```ruby
expect(locator).to have_role(role, timeout: nil)
```


Ensures the [Locator](./locator) points to an element with a given [ARIA role](https://www.w3.org/TR/wai-aria-1.2/#roles).

Note that role is matched as a string, disregarding the ARIA role hierarchy. For example, asserting  a superclass role `"checkbox"` on an element with a subclass role `"switch"` will fail.

**Usage**

```ruby
locator = page.get_by_test_id("save-button")
expect(locator).to have_role("button")
```

## to_have_text

```ruby
expect(locator).to have_text(expected, ignoreCase: nil, timeout: nil, useInnerText: nil)
```


Ensures the [Locator](./locator) points to an element with the given text. All nested elements will be considered when computing the text content of the element. You can use regular expressions for the value as well.

**Details**

When `expected` parameter is a string, Playwright will normalize whitespaces and line breaks both in the actual text and
in the expected string before matching. When regular expression is used, the actual text is matched as is.

**Usage**

```ruby
locator = page.locator(".title")
expect(locator).to have_text(/Welcome, Test User/)
expect(locator).to have_text(/Welcome, .*/)
```

If you pass an array as an expected value, the expectations are:
1. Locator resolves to a list of elements.
1. The number of elements equals the number of expected values in the array.
1. Elements from the list have text matching expected array values, one by one, in order.

For example, consider the following list:

```html
<ul>
  <li>Text 1</li>
  <li>Text 2</li>
  <li>Text 3</li>
</ul>
```

Let's see how we can use the assertion:

```ruby
# ✓ Has the right items in the right order
expect(page.locator("ul > li")).to have_text(["Text 1", "Text 2", "Text 3"])

# ✖ Wrong order
expect(page.locator("ul > li")).to have_text(["Text 3", "Text 2", "Text 1"])

# ✖ Last item does not match
expect(page.locator("ul > li")).to have_text(["Text 1", "Text 2", "Text"])

# ✖ Locator points to the outer list element, not to the list items
expect(page.locator("ul")).to have_text(["Text 1", "Text 2", "Text 3"])
```

## to_have_value

```ruby
expect(locator).to have_value(value, timeout: nil)
```


Ensures the [Locator](./locator) points to an element with the given input value. You can use regular expressions for the value as well.

**Usage**

```ruby
locator = page.locator("input[type=number]")
expect(locator).to have_value(/^[0-9]$/)
```

## to_have_values

```ruby
expect(locator).to have_values(values, timeout: nil)
```


Ensures the [Locator](./locator) points to multi-select/combobox (i.e. a `select` with the `multiple` attribute) and the specified values are selected.

**Usage**

For example, given the following element:

```html
<select id="favorite-colors" multiple>
  <option value="R">Red</option>
  <option value="G">Green</option>
  <option value="B">Blue</option>
</select>
```

```ruby
locator = page.locator("id=favorite-colors")
locator.select_option(["R", "G"])
expect(locator).to have_values([/R/, /G/])
```

## to_match_aria_snapshot

```ruby
expect(locator).to match_aria_snapshot(expected, timeout: nil)
```


Asserts that the target element matches the given [accessibility snapshot](https://playwright.dev/python/docs/aria-snapshots).

**Usage**

```ruby
page.goto('https://demo.playwright.dev/todomvc/')
expect(page.locator('body')).to match_aria_snapshot(<<~YAML)
- heading "todos"
- textbox "What needs to be done?"
YAML
```
