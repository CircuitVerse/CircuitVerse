module Playwright
  #
  # `Dialog` objects are dispatched by page via the [`event: Page.dialog`] event.
  #
  # An example of using `Dialog` class:
  #
  # ```python sync
  # from playwright.sync_api import sync_playwright, Playwright
  #
  # def handle_dialog(dialog):
  #     print(dialog.message)
  #     dialog.dismiss()
  #
  # def run(playwright: Playwright):
  #     chromium = playwright.chromium
  #     browser = chromium.launch()
  #     page = browser.new_page()
  #     page.on("dialog", handle_dialog)
  #     page.evaluate("alert('1')")
  #     browser.close()
  #
  # with sync_playwright() as playwright:
  #     run(playwright)
  # ```
  #
  # **NOTE**: Dialogs are dismissed automatically, unless there is a [`event: Page.dialog`] listener.
  # When listener is present, it **must** either [`method: Dialog.accept`] or [`method: Dialog.dismiss`] the dialog - otherwise the page will [freeze](https://developer.mozilla.org/en-US/docs/Web/JavaScript/EventLoop#never_blocking) waiting for the dialog, and actions like click will never finish.
  class Dialog < PlaywrightApi

    #
    # Returns when the dialog has been accepted.
    def accept(promptText: nil)
      wrap_impl(@impl.accept(promptText: unwrap_impl(promptText)))
    end

    #
    # If dialog is prompt, returns default prompt value. Otherwise, returns empty string.
    def default_value
      wrap_impl(@impl.default_value)
    end

    #
    # Returns when the dialog has been dismissed.
    def dismiss
      wrap_impl(@impl.dismiss)
    end

    #
    # A message displayed in the dialog.
    def message
      wrap_impl(@impl.message)
    end

    #
    # The page that initiated this dialog, if available.
    def page
      wrap_impl(@impl.page)
    end

    #
    # Returns dialog's type, can be one of `alert`, `beforeunload`, `confirm` or `prompt`.
    def type
      wrap_impl(@impl.type)
    end

    # @nodoc
    def accept_async(promptText: nil)
      wrap_impl(@impl.accept_async(promptText: unwrap_impl(promptText)))
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def once(event, callback)
      event_emitter_proxy.once(event, callback)
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def on(event, callback)
      event_emitter_proxy.on(event, callback)
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def off(event, callback)
      event_emitter_proxy.off(event, callback)
    end

    private def event_emitter_proxy
      @event_emitter_proxy ||= EventEmitterProxy.new(self, @impl)
    end
  end
end
