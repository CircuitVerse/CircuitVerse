---
sidebar_position: 10
---

# Dialog


[Dialog](./dialog) objects are dispatched by page via the [`event: Page.dialog`] event.

An example of using [Dialog](./dialog) class:

```ruby
def handle_dialog(dialog)
  puts "[#{dialog.type}] #{dialog.message}"
  if dialog.message =~ /foo/
    dialog.accept
  else
    dialog.dismiss
  end
end

page.on("dialog", method(:handle_dialog))
page.evaluate("confirm('foo')") # will be accepted
# => [confirm] foo
page.evaluate("alert('bar')") # will be dismissed
# => [alert] bar
```

**NOTE**: Dialogs are dismissed automatically, unless there is a [`event: Page.dialog`] listener.
When listener is present, it **must** either [Dialog#accept](./dialog#accept) or [Dialog#dismiss](./dialog#dismiss) the dialog - otherwise the page will [freeze](https://developer.mozilla.org/en-US/docs/Web/JavaScript/EventLoop#never_blocking) waiting for the dialog, and actions like click will never finish.

## accept

```
def accept(promptText: nil)
```


Returns when the dialog has been accepted.

## default_value

```
def default_value
```


If dialog is prompt, returns default prompt value. Otherwise, returns empty string.

## dismiss

```
def dismiss
```


Returns when the dialog has been dismissed.

## message

```
def message
```


A message displayed in the dialog.

## page

```
def page
```


The page that initiated this dialog, if available.

## type

```
def type
```


Returns dialog's type, can be one of `alert`, `beforeunload`, `confirm` or `prompt`.
