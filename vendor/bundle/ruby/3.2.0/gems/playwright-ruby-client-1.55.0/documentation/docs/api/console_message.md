---
sidebar_position: 10
---

# ConsoleMessage


[ConsoleMessage](./console_message) objects are dispatched by page via the [`event: Page.console`] event.
For each console message logged in the page there will be corresponding event in the Playwright
context.

```ruby
# Listen for all console logs
page.on("console", ->(msg) { puts msg.text })

# Listen for all console events and handle errors
page.on("console", ->(msg) {
  if msg.type == 'error'
    puts "error: #{msg.text}"
  end
})

# Get the next console log
msg = page.expect_console_message do
  # Issue console.log inside the page
  page.evaluate("console.error('hello', 42, { foo: 'bar' })")
end

# Deconstruct print arguments
msg.args[0].json_value # => 'hello'
msg.args[1].json_value # => 42
msg.args[2].json_value # => { 'foo' => 'bar' }
```

## args

```
def args
```


List of arguments passed to a `console` function call. See also [`event: Page.console`].

## location

```
def location
```



## page

```
def page
```


The page that produced this console message, if any.

## text

```
def text
```


The text of the console message.

## type

```
def type
```


