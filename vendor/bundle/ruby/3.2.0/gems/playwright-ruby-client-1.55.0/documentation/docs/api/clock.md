---
sidebar_position: 10
---

# Clock


Accurately simulating time-dependent behavior is essential for verifying the correctness of applications. Learn more about [clock emulation](https://playwright.dev/python/docs/clock).

Note that clock is installed for the entire [BrowserContext](./browser_context), so the time
in all the pages and iframes is controlled by the same clock.

## fast_forward

```
def fast_forward(ticks)
```


Advance the clock by jumping forward in time. Only fires due timers at most once. This is equivalent to user closing the laptop lid for a while and
reopening it later, after given time.

**Usage**

```ruby
page.clock.fast_forward(1000)
page.clock.fast_forward("30:00")
```

## install

```
def install(time: nil)
```


Install fake implementations for the following time-related functions:
- `Date`
- `setTimeout`
- `clearTimeout`
- `setInterval`
- `clearInterval`
- `requestAnimationFrame`
- `cancelAnimationFrame`
- `requestIdleCallback`
- `cancelIdleCallback`
- `performance`

Fake timers are used to manually control the flow of time in tests. They allow you to advance time, fire timers, and control the behavior of time-dependent functions. See [Clock#run_for](./clock#run_for) and [Clock#fast_forward](./clock#fast_forward) for more information.

## run_for

```
def run_for(ticks)
```


Advance the clock, firing all the time-related callbacks.

**Usage**

```ruby
page.clock.run_for(1000)
page.clock.run_for("30:00")
```

## pause_at

```
def pause_at(time)
```


Advance the clock by jumping forward in time and pause the time. Once this method is called, no timers
are fired unless [Clock#run_for](./clock#run_for), [Clock#fast_forward](./clock#fast_forward), [Clock#pause_at](./clock#pause_at) or [Clock#resume](./clock#resume) is called.

Only fires due timers at most once.
This is equivalent to user closing the laptop lid for a while and reopening it at the specified time and
pausing.

**Usage**

```ruby
page.clock.pause_at(Time.parse("2020-02-02"))
page.clock.pause_at("2020-02-02")
```

For best results, install the clock before navigating the page and set it to a time slightly before the intended test time. This ensures that all timers run normally during page loading, preventing the page from getting stuck. Once the page has fully loaded, you can safely use [Clock#pause_at](./clock#pause_at) to pause the clock.

```ruby
# Initialize clock with some time before the test time and let the page load
# naturally. `Date.now` will progress as the timers fire.
page.clock.install(Time.parse("2024-12-10T08:00:00Z"))
page.goto("http://localhost:3333")
page.clock.pause_at(Time.parse("2024-12-10T10:00:00Z"))
```

## resume

```
def resume
```


Resumes timers. Once this method is called, time resumes flowing, timers are fired as usual.

## set_fixed_time

```
def set_fixed_time(time)
```
alias: `fixed_time=`


Makes `Date.now` and `new Date()` return fixed fake time at all times,
keeps all the timers running.

Use this method for simple scenarios where you only need to test with a predefined time. For more advanced scenarios, use [Clock#install](./clock#install) instead. Read docs on [clock emulation](https://playwright.dev/python/docs/clock) to learn more.

**Usage**

```ruby
page.clock.set_fixed_time(Time.now)
page.clock.set_fixed_time(Time.parse("2020-02-02"))
page.clock.set_fixed_time("2020-02-02")

# or we can use the alias
page.clock.fixed_time = Time.now
page.clock.fixed_time = Time.parse("2020-02-02")
page.clock.fixed_time = "2020-02-02"
```

## set_system_time

```
def set_system_time(time)
```
alias: `system_time=`


Sets system time, but does not trigger any timers. Use this to test how the web page reacts to a time shift, for example switching from summer to winter time, or changing time zones.

**Usage**

```ruby
page.clock.set_system_time(Time.now)
page.clock.set_system_time(Time.parse("2020-02-02"))
page.clock.set_system_time("2020-02-02")

# or we can use the alias
page.clock.system_time = Time.now
page.clock.system_time = Time.parse("2020-02-02")
page.clock.system_time = "2020-02-02"
```
