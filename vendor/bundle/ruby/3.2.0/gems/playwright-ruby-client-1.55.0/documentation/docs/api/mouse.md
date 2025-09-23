---
sidebar_position: 10
---

# Mouse


The Mouse class operates in main-frame CSS pixels relative to the top-left corner of the viewport.

**NOTE**: If you want to debug where the mouse moved, you can use the [Trace viewer](https://playwright.dev/python/docs/trace-viewer-intro) or [Playwright Inspector](https://playwright.dev/python/docs/running-tests). A red dot showing the location of the mouse will be shown for every mouse action.

Every `page` object has its own Mouse, accessible with [Page#mouse](./page#mouse).

```ruby
# using ‘page.mouse’ to trace a 100x100 square.
page.mouse.move(0, 0)
page.mouse.down
page.mouse.move(0, 100)
page.mouse.move(100, 100)
page.mouse.move(100, 0)
page.mouse.move(0, 0)
page.mouse.up
```

## click

```
def click(
      x,
      y,
      button: nil,
      clickCount: nil,
      delay: nil)
```


Shortcut for [Mouse#move](./mouse#move), [Mouse#down](./mouse#down), [Mouse#up](./mouse#up).

## dblclick

```
def dblclick(x, y, button: nil, delay: nil)
```


Shortcut for [Mouse#move](./mouse#move), [Mouse#down](./mouse#down), [Mouse#up](./mouse#up), [Mouse#down](./mouse#down) and
[Mouse#up](./mouse#up).

## down

```
def down(button: nil, clickCount: nil)
```


Dispatches a `mousedown` event.

## move

```
def move(x, y, steps: nil)
```


Dispatches a `mousemove` event.

## up

```
def up(button: nil, clickCount: nil)
```


Dispatches a `mouseup` event.

## wheel

```
def wheel(deltaX, deltaY)
```


Dispatches a `wheel` event. This method is usually used to manually scroll the page. See [scrolling](https://playwright.dev/python/docs/input#scrolling) for alternative ways to scroll.

**NOTE**: Wheel events may cause scrolling if they are not handled, and this method does not
wait for the scrolling to finish before returning.
