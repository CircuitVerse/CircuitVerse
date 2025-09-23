---
sidebar_position: 10
---

# CDPSession


The [CDPSession](./cdp_session) instances are used to talk raw Chrome Devtools Protocol:
- protocol methods can be called with `session.send_message` method.
- protocol events can be subscribed to with `session.on` method.

Useful links:
- Documentation on DevTools Protocol can be found here: [DevTools Protocol Viewer](https://chromedevtools.github.io/devtools-protocol/).
- Getting Started with DevTools Protocol: https://github.com/aslushnikov/getting-started-with-cdp/blob/master/README.md

```ruby
client = page.context.new_cdp_session(page)
client.send_message('Animation.enable')
client.on('Animation.animationCreated', -> (_) { puts 'Animation Created' })
response = client.send_message('Animation.getPlaybackRate')
puts "Playback rate is #{response['playbackRate']}"
client.send_message(
  'Animation.setPlaybackRate',
  params: { playbackRate: response['playbackRate'] / 2.0 },
)
```

## detach

```
def detach
```


Detaches the CDPSession from the target. Once detached, the CDPSession object won't emit any events and can't be used to
send messages.

## send_message

```
def send_message(method, params: nil)
```


