module Playwright
  #
  # FrameLocator represents a view to the `iframe` on the page. It captures the logic sufficient to retrieve the `iframe` and locate elements in that iframe. FrameLocator can be created with either [`method: Locator.contentFrame`], [`method: Page.frameLocator`] or [`method: Locator.frameLocator`] method.
  #
  # ```python sync
  # locator = page.locator("my-frame").content_frame.get_by_text("Submit")
  # locator.click()
  # ```
  #
  # **Strictness**
  #
  # Frame locators are strict. This means that all operations on frame locators will throw if more than one element matches a given selector.
  #
  # ```python sync
  # # Throws if there are several frames in DOM:
  # page.locator('.result-frame').content_frame.get_by_role('button').click()
  #
  # # Works because we explicitly tell locator to pick the first frame:
  # page.locator('.result-frame').first.content_frame.get_by_role('button').click()
  # ```
  #
  # **Converting Locator to FrameLocator**
  #
  # If you have a `Locator` object pointing to an `iframe` it can be converted to `FrameLocator` using [`method: Locator.contentFrame`].
  #
  # **Converting FrameLocator to Locator**
  #
  # If you have a `FrameLocator` object it can be converted to `Locator` pointing to the same `iframe` using [`method: FrameLocator.owner`].
  class FrameLocator < PlaywrightApi

    #
    # Returns locator to the first matching frame.
    #
    # @deprecated Use [`method: Locator.first`] followed by [`method: Locator.contentFrame`] instead.
    def first
      wrap_impl(@impl.first)
    end

    #
    # When working with iframes, you can create a frame locator that will enter the iframe and allow selecting elements
    # in that iframe.
    def frame_locator(selector)
      wrap_impl(@impl.frame_locator(unwrap_impl(selector)))
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
    # Returns locator to the last matching frame.
    #
    # @deprecated Use [`method: Locator.last`] followed by [`method: Locator.contentFrame`] instead.
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
    # Returns locator to the n-th matching frame. It's zero based, `nth(0)` selects the first frame.
    #
    # @deprecated Use [`method: Locator.nth`] followed by [`method: Locator.contentFrame`] instead.
    def nth(index)
      wrap_impl(@impl.nth(unwrap_impl(index)))
    end

    #
    # Returns a `Locator` object pointing to the same `iframe` as this frame locator.
    #
    # Useful when you have a `FrameLocator` object obtained somewhere, and later on would like to interact with the `iframe` element.
    #
    # For a reverse operation, use [`method: Locator.contentFrame`].
    #
    # **Usage**
    #
    # ```python sync
    # frame_locator = page.locator("iframe[name=\"embedded\"]").content_frame
    # # ...
    # locator = frame_locator.owner
    # expect(locator).to_be_visible()
    # ```
    def owner
      wrap_impl(@impl.owner)
    end
  end
end
