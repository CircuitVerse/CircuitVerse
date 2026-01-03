---
sidebar_position: 10
---

# Selectors


Selectors can be used to install custom selector engines. See [extensibility](https://playwright.dev/python/docs/extensibility) for more
information.

## register

```
def register(name, script: nil, contentScript: nil, path: nil)
```


Selectors must be registered before creating the page.

**Usage**

An example of registering selector engine that queries elements based on a tag name:

```ruby
tag_selector = <<~JAVASCRIPT
{
    // Returns the first element matching given selector in the root's subtree.
    query(root, selector) {
        return root.querySelector(selector);
    },
    // Returns all elements matching given selector in the root's subtree.
    queryAll(root, selector) {
        return Array.from(root.querySelectorAll(selector));
    }
}
JAVASCRIPT

# Register the engine. Selectors will be prefixed with "tag=".
playwright.selectors.register("tag", script: tag_selector)
playwright.chromium.launch do |browser|
  page = browser.new_page
  page.content = '<div><button>Click me</button></div>'

  # Use the selector prefixed with its name.
  button = page.locator('tag=button')
  # Combine it with other selector engines.
  page.locator('tag=div').get_by_text('Click me').click

  # Can use it in any methods supporting selectors.
  button_count = page.locator('tag=button').count
  button_count # => 1
end
```

## set_test_id_attribute

```
def set_test_id_attribute(attributeName)
```
alias: `test_id_attribute=`


Defines custom attribute name to be used in [Page#get_by_test_id](./page#get_by_test_id). `data-testid` is used by default.
