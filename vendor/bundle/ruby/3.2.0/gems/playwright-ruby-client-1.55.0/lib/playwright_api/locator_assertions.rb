module Playwright
  #
  # The `LocatorAssertions` class provides assertion methods that can be used to make assertions about the `Locator` state in the tests.
  #
  # ```python sync
  # from playwright.sync_api import Page, expect
  #
  # def test_status_becomes_submitted(page: Page) -> None:
  #     # ..
  #     page.get_by_role("button").click()
  #     expect(page.locator(".status")).to_have_text("Submitted")
  # ```
  class LocatorAssertions < PlaywrightApi

    #
    # The opposite of [`method: LocatorAssertions.toBeAttached`].
    def not_to_be_attached(attached: nil, timeout: nil)
      wrap_impl(@impl.not_to_be_attached(attached: unwrap_impl(attached), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toBeChecked`].
    def not_to_be_checked(timeout: nil)
      wrap_impl(@impl.not_to_be_checked(timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toBeDisabled`].
    def not_to_be_disabled(timeout: nil)
      wrap_impl(@impl.not_to_be_disabled(timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toBeEditable`].
    def not_to_be_editable(editable: nil, timeout: nil)
      wrap_impl(@impl.not_to_be_editable(editable: unwrap_impl(editable), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toBeEmpty`].
    def not_to_be_empty(timeout: nil)
      wrap_impl(@impl.not_to_be_empty(timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toBeEnabled`].
    def not_to_be_enabled(enabled: nil, timeout: nil)
      wrap_impl(@impl.not_to_be_enabled(enabled: unwrap_impl(enabled), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toBeFocused`].
    def not_to_be_focused(timeout: nil)
      wrap_impl(@impl.not_to_be_focused(timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toBeHidden`].
    def not_to_be_hidden(timeout: nil)
      wrap_impl(@impl.not_to_be_hidden(timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toBeInViewport`].
    def not_to_be_in_viewport(ratio: nil, timeout: nil)
      wrap_impl(@impl.not_to_be_in_viewport(ratio: unwrap_impl(ratio), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toBeVisible`].
    def not_to_be_visible(timeout: nil, visible: nil)
      wrap_impl(@impl.not_to_be_visible(timeout: unwrap_impl(timeout), visible: unwrap_impl(visible)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toContainClass`].
    def not_to_contain_class(expected, timeout: nil)
      wrap_impl(@impl.not_to_contain_class(unwrap_impl(expected), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toContainText`].
    def not_to_contain_text(expected, ignoreCase: nil, timeout: nil, useInnerText: nil)
      wrap_impl(@impl.not_to_contain_text(unwrap_impl(expected), ignoreCase: unwrap_impl(ignoreCase), timeout: unwrap_impl(timeout), useInnerText: unwrap_impl(useInnerText)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toHaveAccessibleDescription`].
    def not_to_have_accessible_description(name, ignoreCase: nil, timeout: nil)
      wrap_impl(@impl.not_to_have_accessible_description(unwrap_impl(name), ignoreCase: unwrap_impl(ignoreCase), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toHaveAccessibleErrorMessage`].
    def not_to_have_accessible_error_message(errorMessage, ignoreCase: nil, timeout: nil)
      wrap_impl(@impl.not_to_have_accessible_error_message(unwrap_impl(errorMessage), ignoreCase: unwrap_impl(ignoreCase), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toHaveAccessibleName`].
    def not_to_have_accessible_name(name, ignoreCase: nil, timeout: nil)
      wrap_impl(@impl.not_to_have_accessible_name(unwrap_impl(name), ignoreCase: unwrap_impl(ignoreCase), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toHaveAttribute`].
    def not_to_have_attribute(name, value, ignoreCase: nil, timeout: nil)
      wrap_impl(@impl.not_to_have_attribute(unwrap_impl(name), unwrap_impl(value), ignoreCase: unwrap_impl(ignoreCase), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toHaveClass`].
    def not_to_have_class(expected, timeout: nil)
      wrap_impl(@impl.not_to_have_class(unwrap_impl(expected), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toHaveCount`].
    def not_to_have_count(count, timeout: nil)
      wrap_impl(@impl.not_to_have_count(unwrap_impl(count), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toHaveCSS`].
    def not_to_have_css(name, value, timeout: nil)
      wrap_impl(@impl.not_to_have_css(unwrap_impl(name), unwrap_impl(value), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toHaveId`].
    def not_to_have_id(id, timeout: nil)
      wrap_impl(@impl.not_to_have_id(unwrap_impl(id), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toHaveJSProperty`].
    def not_to_have_js_property(name, value, timeout: nil)
      wrap_impl(@impl.not_to_have_js_property(unwrap_impl(name), unwrap_impl(value), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toHaveRole`].
    def not_to_have_role(role, timeout: nil)
      wrap_impl(@impl.not_to_have_role(unwrap_impl(role), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toHaveText`].
    def not_to_have_text(expected, ignoreCase: nil, timeout: nil, useInnerText: nil)
      wrap_impl(@impl.not_to_have_text(unwrap_impl(expected), ignoreCase: unwrap_impl(ignoreCase), timeout: unwrap_impl(timeout), useInnerText: unwrap_impl(useInnerText)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toHaveValue`].
    def not_to_have_value(value, timeout: nil)
      wrap_impl(@impl.not_to_have_value(unwrap_impl(value), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toHaveValues`].
    def not_to_have_values(values, timeout: nil)
      wrap_impl(@impl.not_to_have_values(unwrap_impl(values), timeout: unwrap_impl(timeout)))
    end

    #
    # The opposite of [`method: LocatorAssertions.toMatchAriaSnapshot`].
    def not_to_match_aria_snapshot(expected, timeout: nil)
      wrap_impl(@impl.not_to_match_aria_snapshot(unwrap_impl(expected), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures that `Locator` points to an element that is [connected](https://developer.mozilla.org/en-US/docs/Web/API/Node/isConnected) to a Document or a ShadowRoot.
    #
    # **Usage**
    #
    # ```python sync
    # expect(page.get_by_text("Hidden text")).to_be_attached()
    # ```
    def to_be_attached(attached: nil, timeout: nil)
      wrap_impl(@impl.to_be_attached(attached: unwrap_impl(attached), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to a checked input.
    #
    # **Usage**
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.get_by_label("Subscribe to newsletter")
    # expect(locator).to_be_checked()
    # ```
    def to_be_checked(checked: nil, indeterminate: nil, timeout: nil)
      wrap_impl(@impl.to_be_checked(checked: unwrap_impl(checked), indeterminate: unwrap_impl(indeterminate), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to a disabled element. Element is disabled if it has "disabled" attribute
    # or is disabled via ['aria-disabled'](https://developer.mozilla.org/en-US/docs/Web/Accessibility/ARIA/Attributes/aria-disabled).
    # Note that only native control elements such as HTML `button`, `input`, `select`, `textarea`, `option`, `optgroup`
    # can be disabled by setting "disabled" attribute. "disabled" attribute on other elements is ignored
    # by the browser.
    #
    # **Usage**
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.locator("button.submit")
    # expect(locator).to_be_disabled()
    # ```
    def to_be_disabled(timeout: nil)
      wrap_impl(@impl.to_be_disabled(timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to an editable element.
    #
    # **Usage**
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.get_by_role("textbox")
    # expect(locator).to_be_editable()
    # ```
    def to_be_editable(editable: nil, timeout: nil)
      wrap_impl(@impl.to_be_editable(editable: unwrap_impl(editable), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to an empty editable element or to a DOM node that has no text.
    #
    # **Usage**
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.locator("div.warning")
    # expect(locator).to_be_empty()
    # ```
    def to_be_empty(timeout: nil)
      wrap_impl(@impl.to_be_empty(timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to an enabled element.
    #
    # **Usage**
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.locator("button.submit")
    # expect(locator).to_be_enabled()
    # ```
    def to_be_enabled(enabled: nil, timeout: nil)
      wrap_impl(@impl.to_be_enabled(enabled: unwrap_impl(enabled), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to a focused DOM node.
    #
    # **Usage**
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.get_by_role("textbox")
    # expect(locator).to_be_focused()
    # ```
    def to_be_focused(timeout: nil)
      wrap_impl(@impl.to_be_focused(timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures that `Locator` either does not resolve to any DOM node, or resolves to a [non-visible](../actionability.md#visible) one.
    #
    # **Usage**
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.locator('.my-element')
    # expect(locator).to_be_hidden()
    # ```
    def to_be_hidden(timeout: nil)
      wrap_impl(@impl.to_be_hidden(timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to an element that intersects viewport, according to the [intersection observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API).
    #
    # **Usage**
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.get_by_role("button")
    # # Make sure at least some part of element intersects viewport.
    # expect(locator).to_be_in_viewport()
    # # Make sure element is fully outside of viewport.
    # expect(locator).not_to_be_in_viewport()
    # # Make sure that at least half of the element intersects viewport.
    # expect(locator).to_be_in_viewport(ratio=0.5)
    # ```
    def to_be_in_viewport(ratio: nil, timeout: nil)
      wrap_impl(@impl.to_be_in_viewport(ratio: unwrap_impl(ratio), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures that `Locator` points to an attached and [visible](../actionability.md#visible) DOM node.
    #
    # To check that at least one element from the list is visible, use [`method: Locator.first`].
    #
    # **Usage**
    #
    # ```python sync
    # # A specific element is visible.
    # expect(page.get_by_text("Welcome")).to_be_visible()
    #
    # # At least one item in the list is visible.
    # expect(page.get_by_test_id("todo-item").first).to_be_visible()
    #
    # # At least one of the two elements is visible, possibly both.
    # expect(
    #     page.get_by_role("button", name="Sign in")
    #     .or_(page.get_by_role("button", name="Sign up"))
    #     .first
    # ).to_be_visible()
    # ```
    def to_be_visible(timeout: nil, visible: nil)
      wrap_impl(@impl.to_be_visible(timeout: unwrap_impl(timeout), visible: unwrap_impl(visible)))
    end

    #
    # Ensures the `Locator` points to an element with given CSS classes. All classes from the asserted value, separated by spaces, must be present in the [Element.classList](https://developer.mozilla.org/en-US/docs/Web/API/Element/classList) in any order.
    #
    # **Usage**
    #
    # ```html
    # <div class='middle selected row' id='component'></div>
    # ```
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.locator("#component")
    # expect(locator).to_contain_class("middle selected row")
    # expect(locator).to_contain_class("selected")
    # expect(locator).to_contain_class("row middle")
    # ```
    #
    # When an array is passed, the method asserts that the list of elements located matches the corresponding list of expected class lists. Each element's class attribute is matched against the corresponding class in the array:
    #
    # ```html
    # <div class='list'>
    #   <div class='component inactive'></div>
    #   <div class='component active'></div>
    #   <div class='component inactive'></div>
    # </div>
    # ```
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.locator(".list > .component")
    # await expect(locator).to_contain_class(["inactive", "active", "inactive"])
    # ```
    def to_contain_class(expected, timeout: nil)
      wrap_impl(@impl.to_contain_class(unwrap_impl(expected), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to an element that contains the given text. All nested elements will be considered when computing the text content of the element. You can use regular expressions for the value as well.
    #
    # **Details**
    #
    # When `expected` parameter is a string, Playwright will normalize whitespaces and line breaks both in the actual text and
    # in the expected string before matching. When regular expression is used, the actual text is matched as is.
    #
    # **Usage**
    #
    # ```python sync
    # import re
    # from playwright.sync_api import expect
    #
    # locator = page.locator('.title')
    # expect(locator).to_contain_text("substring")
    # expect(locator).to_contain_text(re.compile(r"\d messages"))
    # ```
    #
    # If you pass an array as an expected value, the expectations are:
    # 1. Locator resolves to a list of elements.
    # 1. Elements from a **subset** of this list contain text from the expected array, respectively.
    # 1. The matching subset of elements has the same order as the expected array.
    # 1. Each text value from the expected array is matched by some element from the list.
    #
    # For example, consider the following list:
    #
    # ```html
    # <ul>
    #   <li>Item Text 1</li>
    #   <li>Item Text 2</li>
    #   <li>Item Text 3</li>
    # </ul>
    # ```
    #
    # Let's see how we can use the assertion:
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # # ✓ Contains the right items in the right order
    # expect(page.locator("ul > li")).to_contain_text(["Text 1", "Text 3", "Text 4"])
    #
    # # ✖ Wrong order
    # expect(page.locator("ul > li")).to_contain_text(["Text 3", "Text 2"])
    #
    # # ✖ No item contains this text
    # expect(page.locator("ul > li")).to_contain_text(["Some 33"])
    #
    # # ✖ Locator points to the outer list element, not to the list items
    # expect(page.locator("ul")).to_contain_text(["Text 3"])
    # ```
    def to_contain_text(expected, ignoreCase: nil, timeout: nil, useInnerText: nil)
      wrap_impl(@impl.to_contain_text(unwrap_impl(expected), ignoreCase: unwrap_impl(ignoreCase), timeout: unwrap_impl(timeout), useInnerText: unwrap_impl(useInnerText)))
    end

    #
    # Ensures the `Locator` points to an element with a given [accessible description](https://w3c.github.io/accname/#dfn-accessible-description).
    #
    # **Usage**
    #
    # ```python sync
    # locator = page.get_by_test_id("save-button")
    # expect(locator).to_have_accessible_description("Save results to disk")
    # ```
    def to_have_accessible_description(description, ignoreCase: nil, timeout: nil)
      wrap_impl(@impl.to_have_accessible_description(unwrap_impl(description), ignoreCase: unwrap_impl(ignoreCase), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to an element with a given [aria errormessage](https://w3c.github.io/aria/#aria-errormessage).
    #
    # **Usage**
    #
    # ```python sync
    # locator = page.get_by_test_id("username-input")
    # expect(locator).to_have_accessible_error_message("Username is required.")
    # ```
    def to_have_accessible_error_message(errorMessage, ignoreCase: nil, timeout: nil)
      wrap_impl(@impl.to_have_accessible_error_message(unwrap_impl(errorMessage), ignoreCase: unwrap_impl(ignoreCase), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to an element with a given [accessible name](https://w3c.github.io/accname/#dfn-accessible-name).
    #
    # **Usage**
    #
    # ```python sync
    # locator = page.get_by_test_id("save-button")
    # expect(locator).to_have_accessible_name("Save to disk")
    # ```
    def to_have_accessible_name(name, ignoreCase: nil, timeout: nil)
      wrap_impl(@impl.to_have_accessible_name(unwrap_impl(name), ignoreCase: unwrap_impl(ignoreCase), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to an element with given attribute.
    #
    # **Usage**
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.locator("input")
    # expect(locator).to_have_attribute("type", "text")
    # ```
    def to_have_attribute(name, value, ignoreCase: nil, timeout: nil)
      wrap_impl(@impl.to_have_attribute(unwrap_impl(name), unwrap_impl(value), ignoreCase: unwrap_impl(ignoreCase), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to an element with given CSS classes. When a string is provided, it must fully match the element's `class` attribute. To match individual classes use [`method: LocatorAssertions.toContainClass`].
    #
    # **Usage**
    #
    # ```html
    # <div class='middle selected row' id='component'></div>
    # ```
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.locator("#component")
    # expect(locator).to_have_class("middle selected row")
    # expect(locator).to_have_class(re.compile(r"(^|\\s)selected(\\s|$)"))
    # ```
    #
    # When an array is passed, the method asserts that the list of elements located matches the corresponding list of expected class values. Each element's class attribute is matched against the corresponding string or regular expression in the array:
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.locator(".list > .component")
    # expect(locator).to_have_class(["component", "component selected", "component"])
    # ```
    def to_have_class(expected, timeout: nil)
      wrap_impl(@impl.to_have_class(unwrap_impl(expected), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` resolves to an exact number of DOM nodes.
    #
    # **Usage**
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.locator("list > .component")
    # expect(locator).to_have_count(3)
    # ```
    def to_have_count(count, timeout: nil)
      wrap_impl(@impl.to_have_count(unwrap_impl(count), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` resolves to an element with the given computed CSS style.
    #
    # **Usage**
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.get_by_role("button")
    # expect(locator).to_have_css("display", "flex")
    # ```
    def to_have_css(name, value, timeout: nil)
      wrap_impl(@impl.to_have_css(unwrap_impl(name), unwrap_impl(value), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to an element with the given DOM Node ID.
    #
    # **Usage**
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.get_by_role("textbox")
    # expect(locator).to_have_id("lastname")
    # ```
    def to_have_id(id, timeout: nil)
      wrap_impl(@impl.to_have_id(unwrap_impl(id), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to an element with given JavaScript property. Note that this property can be
    # of a primitive type as well as a plain serializable JavaScript object.
    #
    # **Usage**
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # locator = page.locator(".component")
    # expect(locator).to_have_js_property("loaded", True)
    # ```
    def to_have_js_property(name, value, timeout: nil)
      wrap_impl(@impl.to_have_js_property(unwrap_impl(name), unwrap_impl(value), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to an element with a given [ARIA role](https://www.w3.org/TR/wai-aria-1.2/#roles).
    #
    # Note that role is matched as a string, disregarding the ARIA role hierarchy. For example, asserting  a superclass role `"checkbox"` on an element with a subclass role `"switch"` will fail.
    #
    # **Usage**
    #
    # ```python sync
    # locator = page.get_by_test_id("save-button")
    # expect(locator).to_have_role("button")
    # ```
    def to_have_role(role, timeout: nil)
      wrap_impl(@impl.to_have_role(unwrap_impl(role), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to an element with the given text. All nested elements will be considered when computing the text content of the element. You can use regular expressions for the value as well.
    #
    # **Details**
    #
    # When `expected` parameter is a string, Playwright will normalize whitespaces and line breaks both in the actual text and
    # in the expected string before matching. When regular expression is used, the actual text is matched as is.
    #
    # **Usage**
    #
    # ```python sync
    # import re
    # from playwright.sync_api import expect
    #
    # locator = page.locator(".title")
    # expect(locator).to_have_text(re.compile(r"Welcome, Test User"))
    # expect(locator).to_have_text(re.compile(r"Welcome, .*"))
    # ```
    #
    # If you pass an array as an expected value, the expectations are:
    # 1. Locator resolves to a list of elements.
    # 1. The number of elements equals the number of expected values in the array.
    # 1. Elements from the list have text matching expected array values, one by one, in order.
    #
    # For example, consider the following list:
    #
    # ```html
    # <ul>
    #   <li>Text 1</li>
    #   <li>Text 2</li>
    #   <li>Text 3</li>
    # </ul>
    # ```
    #
    # Let's see how we can use the assertion:
    #
    # ```python sync
    # from playwright.sync_api import expect
    #
    # # ✓ Has the right items in the right order
    # expect(page.locator("ul > li")).to_have_text(["Text 1", "Text 2", "Text 3"])
    #
    # # ✖ Wrong order
    # expect(page.locator("ul > li")).to_have_text(["Text 3", "Text 2", "Text 1"])
    #
    # # ✖ Last item does not match
    # expect(page.locator("ul > li")).to_have_text(["Text 1", "Text 2", "Text"])
    #
    # # ✖ Locator points to the outer list element, not to the list items
    # expect(page.locator("ul")).to_have_text(["Text 1", "Text 2", "Text 3"])
    # ```
    def to_have_text(expected, ignoreCase: nil, timeout: nil, useInnerText: nil)
      wrap_impl(@impl.to_have_text(unwrap_impl(expected), ignoreCase: unwrap_impl(ignoreCase), timeout: unwrap_impl(timeout), useInnerText: unwrap_impl(useInnerText)))
    end

    #
    # Ensures the `Locator` points to an element with the given input value. You can use regular expressions for the value as well.
    #
    # **Usage**
    #
    # ```python sync
    # import re
    # from playwright.sync_api import expect
    #
    # locator = page.locator("input[type=number]")
    # expect(locator).to_have_value(re.compile(r"[0-9]"))
    # ```
    def to_have_value(value, timeout: nil)
      wrap_impl(@impl.to_have_value(unwrap_impl(value), timeout: unwrap_impl(timeout)))
    end

    #
    # Ensures the `Locator` points to multi-select/combobox (i.e. a `select` with the `multiple` attribute) and the specified values are selected.
    #
    # **Usage**
    #
    # For example, given the following element:
    #
    # ```html
    # <select id="favorite-colors" multiple>
    #   <option value="R">Red</option>
    #   <option value="G">Green</option>
    #   <option value="B">Blue</option>
    # </select>
    # ```
    #
    # ```python sync
    # import re
    # from playwright.sync_api import expect
    #
    # locator = page.locator("id=favorite-colors")
    # locator.select_option(["R", "G"])
    # expect(locator).to_have_values([re.compile(r"R"), re.compile(r"G")])
    # ```
    def to_have_values(values, timeout: nil)
      wrap_impl(@impl.to_have_values(unwrap_impl(values), timeout: unwrap_impl(timeout)))
    end

    #
    # Asserts that the target element matches the given [accessibility snapshot](../aria-snapshots.md).
    #
    # **Usage**
    #
    # ```python sync
    # page.goto("https://demo.playwright.dev/todomvc/")
    # expect(page.locator('body')).to_match_aria_snapshot('''
    #   - heading "todos"
    #   - textbox "What needs to be done?"
    # ''')
    # ```
    def to_match_aria_snapshot(expected, timeout: nil)
      wrap_impl(@impl.to_match_aria_snapshot(unwrap_impl(expected), timeout: unwrap_impl(timeout)))
    end
  end
end
