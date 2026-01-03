---
sidebar_position: 10
---

# Tracing


API for collecting and saving Playwright traces. Playwright traces can be opened in [Trace Viewer](https://playwright.dev/python/docs/trace-viewer) after Playwright script runs.

**NOTE**: You probably want to [enable tracing in your config file](https://playwright.dev/docs/api/class-testoptions#test-options-trace) instead of using `context.tracing`.

The `context.tracing` API captures browser operations and network activity, but it doesn't record test assertions (like `expect` calls). We recommend [enabling tracing through Playwright Test configuration](https://playwright.dev/docs/api/class-testoptions#test-options-trace), which includes those assertions and provides a more complete trace for debugging test failures.

Start recording a trace before performing actions. At the end, stop tracing and save it to a file.

```ruby
browser.new_context do |context|
  context.tracing.start(screenshots: true, snapshots: true)
  page = context.new_page
  page.goto('https://playwright.dev')
  context.tracing.stop(path: 'trace.zip')
end
```

## start

```
def start(
      name: nil,
      screenshots: nil,
      snapshots: nil,
      sources: nil,
      title: nil)
```


Start tracing.

**NOTE**: You probably want to [enable tracing in your config file](https://playwright.dev/docs/api/class-testoptions#test-options-trace) instead of using `Tracing.start`.

The `context.tracing` API captures browser operations and network activity, but it doesn't record test assertions (like `expect` calls). We recommend [enabling tracing through Playwright Test configuration](https://playwright.dev/docs/api/class-testoptions#test-options-trace), which includes those assertions and provides a more complete trace for debugging test failures.

**Usage**

```ruby
context.tracing.start(screenshots: true, snapshots: true)
page = context.new_page
page.goto('https://playwright.dev')
context.tracing.stop(path: 'trace.zip')
```

## start_chunk

```
def start_chunk(name: nil, title: nil)
```


Start a new trace chunk. If you'd like to record multiple traces on the same [BrowserContext](./browser_context), use [Tracing#start](./tracing#start) once, and then create multiple trace chunks with [Tracing#start_chunk](./tracing#start_chunk) and [Tracing#stop_chunk](./tracing#stop_chunk).

**Usage**

```ruby
context.tracing.start(screenshots: true, snapshots: true)
page = context.new_page
page.goto("https://playwright.dev")

context.tracing.start_chunk
page.get_by_text("Get Started").click
# Everything between start_chunk and stop_chunk will be recorded in the trace.
context.tracing.stop_chunk(path: "trace1.zip")

context.tracing.start_chunk
page.goto("http://example.com")
# Save a second trace file with different actions.
context.tracing.stop_chunk(path: "trace2.zip")
```

## group

```
def group(name, location: nil)
```


**NOTE**: Use `test.step` instead when available.

Creates a new group within the trace, assigning any subsequent API calls to this group, until [Tracing#group_end](./tracing#group_end) is called. Groups can be nested and will be visible in the trace viewer.

**Usage**

```ruby
# All actions between group and group_end
# will be shown in the trace viewer as a group.
context.tracing.group("Open Playwright.dev > API")

page = context.new_page
page.goto("https://playwright.dev/")
page.get_by_role("link", name: "API").click

context.tracing.group_end
```

## group_end

```
def group_end
```


Closes the last group created by [Tracing#group](./tracing#group).

## stop

```
def stop(path: nil)
```


Stop tracing.

## stop_chunk

```
def stop_chunk(path: nil)
```


Stop the trace chunk. See [Tracing#start_chunk](./tracing#start_chunk) for more details about multiple trace chunks.
