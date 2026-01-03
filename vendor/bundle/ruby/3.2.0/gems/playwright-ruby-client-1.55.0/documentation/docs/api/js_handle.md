---
sidebar_position: 10
---

# JSHandle


JSHandle represents an in-page JavaScript object. JSHandles can be created with the [Page#evaluate_handle](./page#evaluate_handle)
method.

```ruby
window_handle = page.evaluate_handle("window")
# ...
```

JSHandle prevents the referenced JavaScript object being garbage collected unless the handle is exposed with
[JSHandle#dispose](./js_handle#dispose). JSHandles are auto-disposed when their origin frame gets navigated or the parent context
gets destroyed.

JSHandle instances can be used as an argument in [Page#eval_on_selector](./page#eval_on_selector), [Page#evaluate](./page#evaluate) and
[Page#evaluate_handle](./page#evaluate_handle) methods.

## as_element

```
def as_element
```


Returns either `null` or the object handle itself, if the object handle is an instance of [ElementHandle](./element_handle).

## dispose

```
def dispose
```


The `jsHandle.dispose` method stops referencing the element handle.

## evaluate

```
def evaluate(expression, arg: nil)
```


Returns the return value of `expression`.

This method passes this handle as the first argument to `expression`.

If `expression` returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then `handle.evaluate` would wait for the promise to resolve and return
its value.

**Usage**

```ruby
tweet_handle = page.query_selector(".tweet .retweets")
tweet_handle.evaluate("node => node.innerText") # => "10 retweets"
```

## evaluate_handle

```
def evaluate_handle(expression, arg: nil)
```


Returns the return value of `expression` as a [JSHandle](./js_handle).

This method passes this handle as the first argument to `expression`.

The only difference between [JSHandle#evaluate](./js_handle#evaluate) and [JSHandle#evaluate_handle](./js_handle#evaluate_handle) is that [JSHandle#evaluate_handle](./js_handle#evaluate_handle) returns [JSHandle](./js_handle).

If the function passed to the [JSHandle#evaluate_handle](./js_handle#evaluate_handle) returns a [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise), then [JSHandle#evaluate_handle](./js_handle#evaluate_handle) would wait
for the promise to resolve and return its value.

See [Page#evaluate_handle](./page#evaluate_handle) for more details.

## get_properties

```
def get_properties
```
alias: `properties`


The method returns a map with **own property names** as keys and JSHandle instances for the property values.

**Usage**

```ruby
page.goto('https://example.com/')
handle = page.evaluate_handle("({window, document})")
properties = handle.properties
puts properties
window_handle = properties["window"]
document_handle = properties["document"]
handle.dispose
```

## get_property

```
def get_property(propertyName)
```


Fetches a single property from the referenced object.

## json_value

```
def json_value
```


Returns a JSON representation of the object. If the object has a `toJSON` function, it **will not be called**.

**NOTE**: The method will return an empty JSON object if the referenced object is not stringifiable. It will throw an error if the
object has circular references.
