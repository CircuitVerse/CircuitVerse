---
sidebar_position: 10
---

# WebSocket


The [WebSocket](./web_socket) class represents WebSocket connections within a page. It provides the ability to inspect and manipulate the data being transmitted and received.

If you want to intercept or modify WebSocket frames, consider using `WebSocketRoute`.

## closed?

```
def closed?
```


Indicates that the web socket has been closed.

## url

```
def url
```


Contains the URL of the WebSocket.

## expect_event

```
def expect_event(event, predicate: nil, timeout: nil, &block)
```


Waits for event to fire and passes its value into the predicate function. Returns when the predicate returns truthy
value. Will throw an error if the webSocket is closed before the event is fired. Returns the event data value.

## wait_for_event

```
def wait_for_event(event, predicate: nil, timeout: nil, &block)
```


**NOTE**: In most cases, you should use [WebSocket#wait_for_event](./web_socket#wait_for_event).

Waits for given `event` to fire. If predicate is provided, it passes
event's value into the `predicate` function and waits for `predicate(event)` to return a truthy value.
Will throw an error if the socket is closed before the `event` is fired.
