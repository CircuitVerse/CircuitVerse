module Playwright
  #
  # Accurately simulating time-dependent behavior is essential for verifying the correctness of applications. Learn more about [clock emulation](../clock.md).
  #
  # Note that clock is installed for the entire `BrowserContext`, so the time
  # in all the pages and iframes is controlled by the same clock.
  class Clock < PlaywrightApi

    #
    # Advance the clock by jumping forward in time. Only fires due timers at most once. This is equivalent to user closing the laptop lid for a while and
    # reopening it later, after given time.
    #
    # **Usage**
    #
    # ```python sync
    # page.clock.fast_forward(1000)
    # page.clock.fast_forward("30:00")
    # ```
    def fast_forward(ticks)
      wrap_impl(@impl.fast_forward(unwrap_impl(ticks)))
    end

    #
    # Install fake implementations for the following time-related functions:
    # - `Date`
    # - `setTimeout`
    # - `clearTimeout`
    # - `setInterval`
    # - `clearInterval`
    # - `requestAnimationFrame`
    # - `cancelAnimationFrame`
    # - `requestIdleCallback`
    # - `cancelIdleCallback`
    # - `performance`
    #
    # Fake timers are used to manually control the flow of time in tests. They allow you to advance time, fire timers, and control the behavior of time-dependent functions. See [`method: Clock.runFor`] and [`method: Clock.fastForward`] for more information.
    def install(time: nil)
      wrap_impl(@impl.install(time: unwrap_impl(time)))
    end

    #
    # Advance the clock, firing all the time-related callbacks.
    #
    # **Usage**
    #
    # ```python sync
    # page.clock.run_for(1000);
    # page.clock.run_for("30:00")
    # ```
    def run_for(ticks)
      wrap_impl(@impl.run_for(unwrap_impl(ticks)))
    end

    #
    # Advance the clock by jumping forward in time and pause the time. Once this method is called, no timers
    # are fired unless [`method: Clock.runFor`], [`method: Clock.fastForward`], [`method: Clock.pauseAt`] or [`method: Clock.resume`] is called.
    #
    # Only fires due timers at most once.
    # This is equivalent to user closing the laptop lid for a while and reopening it at the specified time and
    # pausing.
    #
    # **Usage**
    #
    # ```python sync
    # page.clock.pause_at(datetime.datetime(2020, 2, 2))
    # page.clock.pause_at("2020-02-02")
    # ```
    #
    # For best results, install the clock before navigating the page and set it to a time slightly before the intended test time. This ensures that all timers run normally during page loading, preventing the page from getting stuck. Once the page has fully loaded, you can safely use [`method: Clock.pauseAt`] to pause the clock.
    #
    # ```python sync
    # # Initialize clock with some time before the test time and let the page load
    # # naturally. `Date.now` will progress as the timers fire.
    # page.clock.install(time=datetime.datetime(2024, 12, 10, 8, 0, 0))
    # page.goto("http://localhost:3333")
    # page.clock.pause_at(datetime.datetime(2024, 12, 10, 10, 0, 0))
    # ```
    def pause_at(time)
      wrap_impl(@impl.pause_at(unwrap_impl(time)))
    end

    #
    # Resumes timers. Once this method is called, time resumes flowing, timers are fired as usual.
    def resume
      wrap_impl(@impl.resume)
    end

    #
    # Makes `Date.now` and `new Date()` return fixed fake time at all times,
    # keeps all the timers running.
    #
    # Use this method for simple scenarios where you only need to test with a predefined time. For more advanced scenarios, use [`method: Clock.install`] instead. Read docs on [clock emulation](../clock.md) to learn more.
    #
    # **Usage**
    #
    # ```python sync
    # page.clock.set_fixed_time(datetime.datetime.now())
    # page.clock.set_fixed_time(datetime.datetime(2020, 2, 2))
    # page.clock.set_fixed_time("2020-02-02")
    # ```
    def set_fixed_time(time)
      wrap_impl(@impl.set_fixed_time(unwrap_impl(time)))
    end
    alias_method :fixed_time=, :set_fixed_time

    #
    # Sets system time, but does not trigger any timers. Use this to test how the web page reacts to a time shift, for example switching from summer to winter time, or changing time zones.
    #
    # **Usage**
    #
    # ```python sync
    # page.clock.set_system_time(datetime.datetime.now())
    # page.clock.set_system_time(datetime.datetime(2020, 2, 2))
    # page.clock.set_system_time("2020-02-02")
    # ```
    def set_system_time(time)
      wrap_impl(@impl.set_system_time(unwrap_impl(time)))
    end
    alias_method :system_time=, :set_system_time
  end
end
