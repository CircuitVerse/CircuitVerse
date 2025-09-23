module Playwright
  class AndroidInput < PlaywrightApi

    #
    # Performs a drag between `from` and `to` points.
    def drag(from, to, steps)
      wrap_impl(@impl.drag(unwrap_impl(from), unwrap_impl(to), unwrap_impl(steps)))
    end

    #
    # Presses the `key`.
    def press(key)
      wrap_impl(@impl.press(unwrap_impl(key)))
    end

    #
    # Swipes following the path defined by `segments`.
    def swipe(from, segments, steps)
      raise NotImplementedError.new('swipe is not implemented yet.')
    end

    #
    # Taps at the specified `point`.
    def tap_point(point)
      wrap_impl(@impl.tap_point(unwrap_impl(point)))
    end

    #
    # Types `text` into currently focused widget.
    def type(text)
      wrap_impl(@impl.type(unwrap_impl(text)))
    end
  end
end
