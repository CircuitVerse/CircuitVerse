module Playwright
  #
  # `ConsoleMessage` objects are dispatched by page via the [`event: Page.console`] event.
  # For each console message logged in the page there will be corresponding event in the Playwright
  # context.
  #
  # ```python sync
  # # Listen for all console logs
  # page.on("console", lambda msg: print(msg.text))
  #
  # # Listen for all console events and handle errors
  # page.on("console", lambda msg: print(f"error: {msg.text}") if msg.type == "error" else None)
  #
  # # Get the next console log
  # with page.expect_console_message() as msg_info:
  #     # Issue console.log inside the page
  #     page.evaluate("console.log('hello', 42, { foo: 'bar' })")
  # msg = msg_info.value
  #
  # # Deconstruct print arguments
  # msg.args[0].json_value() # hello
  # msg.args[1].json_value() # 42
  # ```
  class ConsoleMessage < PlaywrightApi

    #
    # List of arguments passed to a `console` function call. See also [`event: Page.console`].
    def args
      wrap_impl(@impl.args)
    end

    def location
      wrap_impl(@impl.location)
    end

    #
    # The page that produced this console message, if any.
    def page
      wrap_impl(@impl.page)
    end

    #
    # The text of the console message.
    def text
      wrap_impl(@impl.text)
    end

    def type
      wrap_impl(@impl.type)
    end
  end
end
