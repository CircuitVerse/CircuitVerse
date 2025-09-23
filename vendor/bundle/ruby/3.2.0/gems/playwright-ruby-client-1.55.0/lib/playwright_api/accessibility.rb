module Playwright
  #
  # The Accessibility class provides methods for inspecting Chromium's accessibility tree. The accessibility tree is used by
  # assistive technology such as [screen readers](https://en.wikipedia.org/wiki/Screen_reader) or
  # [switches](https://en.wikipedia.org/wiki/Switch_access).
  #
  # Accessibility is a very platform-specific thing. On different platforms, there are different screen readers that might
  # have wildly different output.
  #
  # Rendering engines of Chromium, Firefox and WebKit have a concept of "accessibility tree", which is then translated into different
  # platform-specific APIs. Accessibility namespace gives access to this Accessibility Tree.
  #
  # Most of the accessibility tree gets filtered out when converting from internal browser AX Tree to Platform-specific AX-Tree or by
  # assistive technologies themselves. By default, Playwright tries to approximate this filtering, exposing only the
  # "interesting" nodes of the tree.
  class Accessibility < PlaywrightApi

    #
    # Captures the current state of the accessibility tree. The returned object represents the root accessible node of the
    # page.
    #
    # **NOTE**: The Chromium accessibility tree contains nodes that go unused on most platforms and by most screen readers. Playwright
    # will discard them as well for an easier to process tree, unless `interestingOnly` is set to `false`.
    #
    # **Usage**
    #
    # An example of dumping the entire accessibility tree:
    #
    # ```python sync
    # snapshot = page.accessibility.snapshot()
    # print(snapshot)
    # ```
    #
    # An example of logging the focused node's name:
    #
    # ```python sync
    # def find_focused_node(node):
    #     if node.get("focused"):
    #         return node
    #     for child in (node.get("children") or []):
    #         found_node = find_focused_node(child)
    #         if found_node:
    #             return found_node
    #     return None
    #
    # snapshot = page.accessibility.snapshot()
    # node = find_focused_node(snapshot)
    # if node:
    #     print(node["name"])
    # ```
    #
    # @deprecated This method is deprecated. Please use other libraries such as [Axe](https://www.deque.com/axe/) if you need to test page accessibility. See our Node.js [guide](https://playwright.dev/docs/accessibility-testing) for integration with Axe.
    def snapshot(interestingOnly: nil, root: nil)
      wrap_impl(@impl.snapshot(interestingOnly: unwrap_impl(interestingOnly), root: unwrap_impl(root)))
    end
  end
end
