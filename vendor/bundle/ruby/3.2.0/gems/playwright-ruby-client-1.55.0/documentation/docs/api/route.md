---
sidebar_position: 10
---

# Route


Whenever a network route is set up with [Page#route](./page#route) or [BrowserContext#route](./browser_context#route), the [Route](./route) object
allows to handle the route.

Learn more about [networking](https://playwright.dev/python/docs/network).

## abort

```
def abort(errorCode: nil)
```


Aborts the route's request.

## continue

```
def continue(headers: nil, method: nil, postData: nil, url: nil)
```


Sends route's request to the network with optional overrides.

**Usage**

```ruby
def handle(route, request)
  # override headers
  headers = request.headers
  headers['foo'] = 'bar' # set "foo" header
  headers['user-agent'] = 'Unknown Browser' # modify user-agent
  headers.delete('bar') # remove "bar" header

  route.continue(headers: headers)
end
page.route("**/*", method(:handle))
```

**Details**

The `headers` option applies to both the routed request and any redirects it initiates. However, `url`, `method`, and `postData` only apply to the original request and are not carried over to redirected requests.

[Route#continue](./route#continue) will immediately send the request to the network, other matching handlers won't be invoked. Use [Route#fallback](./route#fallback) If you want next matching handler in the chain to be invoked.

**NOTE**: The `Cookie` header cannot be overridden using this method. If a value is provided, it will be ignored, and the cookie will be loaded from the browser's cookie store. To set custom cookies, use [BrowserContext#add_cookies](./browser_context#add_cookies).

## fallback

```
def fallback(headers: nil, method: nil, postData: nil, url: nil)
```


Continues route's request with optional overrides. The method is similar to [Route#continue](./route#continue) with the difference that other matching handlers will be invoked before sending the request.

**Usage**

When several routes match the given pattern, they run in the order opposite to their registration.
That way the last registered route can always override all the previous ones. In the example below,
request will be handled by the bottom-most handler first, then it'll fall back to the previous one and
in the end will be aborted by the first registered route.

```ruby
page.route("**/*", -> (route,_) { route.abort })  # Runs last.
page.route("**/*", -> (route,_) { route.fallback })  # Runs second.
page.route("**/*", -> (route,_) { route.fallback })  # Runs first.
```

Registering multiple routes is useful when you want separate handlers to
handle different kinds of requests, for example API calls vs page resources or
GET requests vs POST requests as in the example below.

```ruby
# Handle GET requests.
def handle_post(route, request)
  if request.method != "GET"
    route.fallback
    return
  end

  # Handling GET only.
  # ...
end

# Handle POST requests.
def handle_post(route, request)
  if request.method != "POST"
    route.fallback
    return
  end

  # Handling POST only.
  # ...
end

page.route("**/*", handle_get)
page.route("**/*", handle_post)
```

One can also modify request while falling back to the subsequent handler, that way intermediate
route handler can modify url, method, headers and postData of the request.

```ruby
def handle(route, request)
  # override headers
  headers = request.headers
  headers['foo'] = 'bar' # set "foo" header
  headers['user-agent'] = 'Unknown Browser' # modify user-agent
  headers.delete('bar') # remove "bar" header

  route.fallback(headers: headers)
end
page.route("**/*", method(:handle))
```

Use [Route#continue](./route#continue) to immediately send the request to the network, other matching handlers won't be invoked in that case.

## fetch

```
def fetch(
      headers: nil,
      maxRedirects: nil,
      maxRetries: nil,
      method: nil,
      postData: nil,
      timeout: nil,
      url: nil)
```


Performs the request and fetches result without fulfilling it, so that the response
could be modified and then fulfilled.

**Usage**

```ruby
def handle(route, request)
  response = route.fetch
  json = response.json
  json["message"]["big_red_dog"] = []

  route.fulfill(response: response, json: json)
end
page.route("https://dog.ceo/api/breeds/list/all", method(:handle))
```

**Details**

Note that `headers` option will apply to the fetched request as well as any redirects initiated by it. If you want to only apply `headers` to the original request, but not to redirects, look into [Route#continue](./route#continue) instead.

## fulfill

```
def fulfill(
      body: nil,
      contentType: nil,
      headers: nil,
      json: nil,
      path: nil,
      response: nil,
      status: nil)
```


Fulfills route's request with given response.

**Usage**

An example of fulfilling all requests with 404 responses:

```ruby
page.route("**/*", ->(route, request) {
  route.fulfill(
    status: 404,
    contentType: 'text/plain',
    body: 'not found!!',
  )
})
```

An example of serving static file:

```ruby
page.route("**/xhr_endpoint", ->(route, _) { route.fulfill(path: "mock_data.json") })
```

## request

```
def request
```


A request to be routed.
