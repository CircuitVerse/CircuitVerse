---
sidebar_position: 10
---

# Touchscreen


The Touchscreen class operates in main-frame CSS pixels relative to the top-left corner of the viewport. Methods on the
touchscreen can only be used in browser contexts that have been initialized with `hasTouch` set to true.

This class is limited to emulating tap gestures. For examples of other gestures simulated by manually dispatching touch events, see the [emulating legacy touch events](https://playwright.dev/python/docs/touch-events) page.

## tap_point

```
def tap_point(x, y)
```


Dispatches a `touchstart` and `touchend` event with a single touch at the position (`x`,`y`).

**NOTE**: [Page#tap_point](./page#tap_point) the method will throw if `hasTouch` option of the browser context is false.
