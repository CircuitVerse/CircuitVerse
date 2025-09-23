module Playwright
  #
  # Keyboard provides an api for managing a virtual keyboard. The high level api is [`method: Keyboard.type`], which takes
  # raw characters and generates proper `keydown`, `keypress`/`input`, and `keyup` events on your page.
  #
  # For finer control, you can use [`method: Keyboard.down`], [`method: Keyboard.up`], and [`method: Keyboard.insertText`]
  # to manually fire events as if they were generated from a real keyboard.
  #
  # An example of holding down `Shift` in order to select and delete some text:
  #
  # ```python sync
  # page.keyboard.type("Hello World!")
  # page.keyboard.press("ArrowLeft")
  # page.keyboard.down("Shift")
  # for i in range(6):
  #     page.keyboard.press("ArrowLeft")
  # page.keyboard.up("Shift")
  # page.keyboard.press("Backspace")
  # # result text will end up saying "Hello!"
  # ```
  #
  # An example of pressing uppercase `A`
  #
  # ```python sync
  # page.keyboard.press("Shift+KeyA")
  # # or
  # page.keyboard.press("Shift+A")
  # ```
  #
  # An example to trigger select-all with the keyboard
  #
  # ```python sync
  # page.keyboard.press("ControlOrMeta+A")
  # ```
  class Keyboard < PlaywrightApi

    #
    # Dispatches a `keydown` event.
    #
    # `key` can specify the intended
    # [keyboardEvent.key](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key) value or a single character to
    # generate the text for. A superset of the `key` values can be found
    # [here](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values). Examples of the keys are:
    #
    # `F1` - `F12`, `Digit0`- `Digit9`, `KeyA`- `KeyZ`, `Backquote`, `Minus`, `Equal`, `Backslash`, `Backspace`, `Tab`,
    # `Delete`, `Escape`, `ArrowDown`, `End`, `Enter`, `Home`, `Insert`, `PageDown`, `PageUp`, `ArrowRight`, `ArrowUp`, etc.
    #
    # Following modification shortcuts are also supported: `Shift`, `Control`, `Alt`, `Meta`, `ShiftLeft`, `ControlOrMeta`.
    # `ControlOrMeta` resolves to `Control` on Windows and Linux and to `Meta` on macOS.
    #
    # Holding down `Shift` will type the text that corresponds to the `key` in the upper case.
    #
    # If `key` is a single character, it is case-sensitive, so the values `a` and `A` will generate different
    # respective texts.
    #
    # If `key` is a modifier key, `Shift`, `Meta`, `Control`, or `Alt`, subsequent key presses will be sent with that
    # modifier active. To release the modifier key, use [`method: Keyboard.up`].
    #
    # After the key is pressed once, subsequent calls to [`method: Keyboard.down`] will have
    # [repeat](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/repeat) set to true. To release the key, use
    # [`method: Keyboard.up`].
    #
    # **NOTE**: Modifier keys DO influence `keyboard.down`. Holding down `Shift` will type the text in upper case.
    def down(key)
      wrap_impl(@impl.down(unwrap_impl(key)))
    end

    #
    # Dispatches only `input` event, does not emit the `keydown`, `keyup` or `keypress` events.
    #
    # **Usage**
    #
    # ```python sync
    # page.keyboard.insert_text("嗨")
    # ```
    #
    # **NOTE**: Modifier keys DO NOT effect `keyboard.insertText`. Holding down `Shift` will not type the text in upper case.
    def insert_text(text)
      wrap_impl(@impl.insert_text(unwrap_impl(text)))
    end

    #
    # **NOTE**: In most cases, you should use [`method: Locator.press`] instead.
    #
    # `key` can specify the intended
    # [keyboardEvent.key](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key) value or a single character to
    # generate the text for. A superset of the `key` values can be found
    # [here](https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent/key/Key_Values). Examples of the keys are:
    #
    # `F1` - `F12`, `Digit0`- `Digit9`, `KeyA`- `KeyZ`, `Backquote`, `Minus`, `Equal`, `Backslash`, `Backspace`, `Tab`,
    # `Delete`, `Escape`, `ArrowDown`, `End`, `Enter`, `Home`, `Insert`, `PageDown`, `PageUp`, `ArrowRight`, `ArrowUp`, etc.
    #
    # Following modification shortcuts are also supported: `Shift`, `Control`, `Alt`, `Meta`, `ShiftLeft`, `ControlOrMeta`.
    # `ControlOrMeta` resolves to `Control` on Windows and Linux and to `Meta` on macOS.
    #
    # Holding down `Shift` will type the text that corresponds to the `key` in the upper case.
    #
    # If `key` is a single character, it is case-sensitive, so the values `a` and `A` will generate different
    # respective texts.
    #
    # Shortcuts such as `key: "Control+o"`, `key: "Control++` or `key: "Control+Shift+T"` are supported as well. When specified with the
    # modifier, modifier is pressed and being held while the subsequent key is being pressed.
    #
    # **Usage**
    #
    # ```python sync
    # page = browser.new_page()
    # page.goto("https://keycode.info")
    # page.keyboard.press("a")
    # page.screenshot(path="a.png")
    # page.keyboard.press("ArrowLeft")
    # page.screenshot(path="arrow_left.png")
    # page.keyboard.press("Shift+O")
    # page.screenshot(path="o.png")
    # browser.close()
    # ```
    #
    # Shortcut for [`method: Keyboard.down`] and [`method: Keyboard.up`].
    def press(key, delay: nil)
      wrap_impl(@impl.press(unwrap_impl(key), delay: unwrap_impl(delay)))
    end

    #
    # **NOTE**: In most cases, you should use [`method: Locator.fill`] instead. You only need to press keys one by one if there is special keyboard handling on the page - in this case use [`method: Locator.pressSequentially`].
    #
    # Sends a `keydown`, `keypress`/`input`, and `keyup` event for each character in the text.
    #
    # To press a special key, like `Control` or `ArrowDown`, use [`method: Keyboard.press`].
    #
    # **Usage**
    #
    # ```python sync
    # page.keyboard.type("Hello") # types instantly
    # page.keyboard.type("World", delay=100) # types slower, like a user
    # ```
    #
    # **NOTE**: Modifier keys DO NOT effect `keyboard.type`. Holding down `Shift` will not type the text in upper case.
    #
    # **NOTE**: For characters that are not on a US keyboard, only an `input` event will be sent.
    def type(text, delay: nil)
      wrap_impl(@impl.type(unwrap_impl(text), delay: unwrap_impl(delay)))
    end

    #
    # Dispatches a `keyup` event.
    def up(key)
      wrap_impl(@impl.up(unwrap_impl(key)))
    end
  end
end
