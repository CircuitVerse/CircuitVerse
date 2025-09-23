---
sidebar_position: 10
---

# APIResponse


[APIResponse](./api_response) class represents responses returned by [APIRequestContext#get](./api_request_context#get) and similar methods.

```ruby
playwright.chromium.launch do |browser|
  context = browser.new_context
  response = context.request.get("https://example.com/user/repos")

  response.ok? # => true
  response.status # => 200
  response.headers["content-type"] # => "application/json; charset=utf-8"
  response.json # => { "name" => "Foo" }
  response.body # => "{ \"name\" => \"Foo\" }"
end
```

## body

```
def body
```


Returns the buffer with response body.

## dispose

```
def dispose
```


Disposes the body of this response. If not called then the body will stay in memory until the context closes.

## headers

```
def headers
```


An object with all the response HTTP headers associated with this response.

## headers_array

```
def headers_array
```


An array with all the response HTTP headers associated with this response. Header names are not lower-cased.
Headers with multiple entries, such as `Set-Cookie`, appear in the array multiple times.

## json

```
def json
```


Returns the JSON representation of response body.

This method will throw if the response body is not parsable via `JSON.parse`.

## ok

```
def ok
```


Contains a boolean stating whether the response was successful (status in the range 200-299) or not.

## status

```
def status
```


Contains the status code of the response (e.g., 200 for a success).

## status_text

```
def status_text
```


Contains the status text of the response (e.g. usually an "OK" for a success).

## text

```
def text
```


Returns the text representation of response body.

## url

```
def url
```


Contains the URL of the response.
