module Playwright
  #
  # The Touchscreen class operates in main-frame CSS pixels relative to the top-left corner of the viewport. Methods on the
  # touchscreen can only be used in browser contexts that have been initialized with `hasTouch` set to true.
  #
  # This class is limited to emulating tap gestures. For examples of other gestures simulated by manually dispatching touch events, see the [emulating legacy touch events](../touch-events.md) page.
  class Touchscreen < PlaywrightApi

    #
    # Dispatches a `touchstart` and `touchend` event with a single touch at the position (`x`,`y`).
    #
    # **NOTE**: [`method: Page.tap`] the method will throw if `hasTouch` option of the browser context is false.
    def tap_point(x, y)
      wrap_impl(@impl.tap_point(unwrap_impl(x), unwrap_impl(y)))
    end
  end
end
