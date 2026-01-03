---
sidebar_position: 10
---

# Worker


The Worker class represents a [WebWorker](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API). `worker`
event is emitted on the page object to signal a worker creation. `close` event is emitted on the worker object when the
worker is gone.

```ruby
def handle_worker(worker)
  puts "worker created: #{worker.url}"
  worker.once("close", -> (w) { puts "worker destroyed: #{w.url}" })
end

page.on('worker', method(:handle_worker))

puts "current workers:"
page.workers.each do |worker|
  puts "    #{worker.url}"
end
```

## evaluate

```
def evaluate(expression, arg: nil)
```


Returns the return value of `expression`.

If the function passed to the [Worker#evaluate](./worker#evaluate) returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Worker#evaluate](./worker#evaluate) would wait for the promise
to resolve and return its value.

If the function passed to the [Worker#evaluate](./worker#evaluate) returns a non-[Serializable](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify#description) value, then [Worker#evaluate](./worker#evaluate) returns `undefined`. Playwright also supports transferring some
additional values that are not serializable by `JSON`: `-0`, `NaN`, `Infinity`, `-Infinity`.

## evaluate_handle

```
def evaluate_handle(expression, arg: nil)
```


Returns the return value of `expression` as a [JSHandle](./js_handle).

The only difference between [Worker#evaluate](./worker#evaluate) and
[Worker#evaluate_handle](./worker#evaluate_handle) is that [Worker#evaluate_handle](./worker#evaluate_handle)
returns [JSHandle](./js_handle).

If the function passed to the [Worker#evaluate_handle](./worker#evaluate_handle) returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [Worker#evaluate_handle](./worker#evaluate_handle) would wait for
the promise to resolve and return its value.

## url

```
def url
```


