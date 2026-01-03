---
sidebar_position: 10
---

# APIRequestContext


This API is used for the Web API testing. You can use it to trigger API endpoints, configure micro-services, prepare
environment or the service to your e2e test.

Each Playwright browser context has associated with it [APIRequestContext](./api_request_context) instance which shares cookie storage with
the browser context and can be accessed via [BrowserContext#request](./browser_context#request) or [Page#request](./page#request).
It is also possible to create a new APIRequestContext instance manually by calling [APIRequest#new_context](./api_request#new_context).

**Cookie management**

[APIRequestContext](./api_request_context) returned by [BrowserContext#request](./browser_context#request) and [Page#request](./page#request) shares cookie
storage with the corresponding [BrowserContext](./browser_context). Each API request will have `Cookie` header populated with the
values from the browser context. If the API response contains `Set-Cookie` header it will automatically update
[BrowserContext](./browser_context) cookies and requests made from the page will pick them up. This means that if you log in using
this API, your e2e test will be logged in and vice versa.

If you want API requests to not interfere with the browser cookies you should create a new [APIRequestContext](./api_request_context) by
calling [APIRequest#new_context](./api_request#new_context). Such [APIRequestContext](./api_request_context) object will have its own isolated cookie
storage.

```ruby
playwright.chromium.launch do |browser|
  # This will launch a new browser, create a context and page. When making HTTP
  # requests with the internal APIRequestContext (e.g. `context.request` or `page.request`)
  # it will automatically set the cookies to the browser page and vise versa.
  context = browser.new_context(base_url: 'https://api.github,com')
  api_request_context = context.request


  # Create a repository.
  response = api_request_context.post(
    "/user/repos",
    headers: {
      "Accept": "application/vnd.github.v3+json",
      "Authorization": "Bearer #{API_TOKEN}",
    },
    data: { name: 'test-repo-1' },
  )
  response.ok? # => true
  response.json['name'] # => "test-repo-1"

  # Delete a repository.
  response = api_request_context.delete(
    "/repos/YourName/test-repo-1",
    headers: {
      "Accept": "application/vnd.github.v3+json",
      "Authorization": "Bearer #{API_TOKEN}",
    },
  )
  response.ok? # => true
end
```

## delete

```
def delete(
      url,
      data: nil,
      failOnStatusCode: nil,
      form: nil,
      headers: nil,
      ignoreHTTPSErrors: nil,
      maxRedirects: nil,
      maxRetries: nil,
      multipart: nil,
      params: nil,
      timeout: nil)
```


Sends HTTP(S) [DELETE](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/DELETE) request and returns its response.
The method will populate request cookies from the context and update
context cookies from the response. The method will automatically follow redirects.

## dispose

```
def dispose(reason: nil)
```


All responses returned by [APIRequestContext#get](./api_request_context#get) and similar methods are stored in the memory, so that you can later call [APIResponse#body](./api_response#body).This method discards all its resources, calling any method on disposed [APIRequestContext](./api_request_context) will throw an exception.

## fetch

```
def fetch(
      urlOrRequest,
      data: nil,
      failOnStatusCode: nil,
      form: nil,
      headers: nil,
      ignoreHTTPSErrors: nil,
      maxRedirects: nil,
      maxRetries: nil,
      method: nil,
      multipart: nil,
      params: nil,
      timeout: nil)
```


Sends HTTP(S) request and returns its response. The method will populate request cookies from the context and update
context cookies from the response. The method will automatically follow redirects.

**Usage**

JSON objects can be passed directly to the request:

```ruby
data = {
  title: "Book Title",
  body: "John Doe",
}
api_request_context.fetch("https://example.com/api/create_book", method: 'post', data: data)
```

The common way to send file(s) in the body of a request is to upload them as form fields with `multipart/form-data` encoding, by specifiying the `multipart` parameter:

```ruby
api_request_context.fetch(
  "https://example.com/api/upload_script",
  method: 'post',
  multipart: {
    fileField: {
      name: "f.js",
      mimeType: "text/javascript",
      buffer: "console.log(2022);",
    },
  },
)
```

## get

```
def get(
      url,
      data: nil,
      failOnStatusCode: nil,
      form: nil,
      headers: nil,
      ignoreHTTPSErrors: nil,
      maxRedirects: nil,
      maxRetries: nil,
      multipart: nil,
      params: nil,
      timeout: nil)
```


Sends HTTP(S) [GET](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/GET) request and returns its response.
The method will populate request cookies from the context and update
context cookies from the response. The method will automatically follow redirects.

**Usage**

Request parameters can be configured with `params` option, they will be serialized into the URL search parameters:

```ruby
query_params = {
  isbn: "1234",
  page: "23"
}
api_request_context.get("https://example.com/api/get_text", params: query_params)
```

## head

```
def head(
      url,
      data: nil,
      failOnStatusCode: nil,
      form: nil,
      headers: nil,
      ignoreHTTPSErrors: nil,
      maxRedirects: nil,
      maxRetries: nil,
      multipart: nil,
      params: nil,
      timeout: nil)
```


Sends HTTP(S) [HEAD](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/HEAD) request and returns its response.
The method will populate request cookies from the context and update
context cookies from the response. The method will automatically follow redirects.

## patch

```
def patch(
      url,
      data: nil,
      failOnStatusCode: nil,
      form: nil,
      headers: nil,
      ignoreHTTPSErrors: nil,
      maxRedirects: nil,
      maxRetries: nil,
      multipart: nil,
      params: nil,
      timeout: nil)
```


Sends HTTP(S) [PATCH](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/PATCH) request and returns its response.
The method will populate request cookies from the context and update
context cookies from the response. The method will automatically follow redirects.

## post

```
def post(
      url,
      data: nil,
      failOnStatusCode: nil,
      form: nil,
      headers: nil,
      ignoreHTTPSErrors: nil,
      maxRedirects: nil,
      maxRetries: nil,
      multipart: nil,
      params: nil,
      timeout: nil)
```


Sends HTTP(S) [POST](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/POST) request and returns its response.
The method will populate request cookies from the context and update
context cookies from the response. The method will automatically follow redirects.

**Usage**

JSON objects can be passed directly to the request:

```ruby
data = {
  title: "Book Title",
  body: "John Doe",
}
api_request_context.post("https://example.com/api/create_book", data: data)
```

To send form data to the server use `form` option. Its value will be encoded into the request body with `application/x-www-form-urlencoded` encoding (see below how to use `multipart/form-data` form encoding to send files):

```ruby
form_data = {
  title: "Book Title",
  body: "John Doe",
}
api_request_context.post("https://example.com/api/find_book", form: form_data)
```

The common way to send file(s) in the body of a request is to upload them as form fields with `multipart/form-data` encoding. Use `FormData` to construct request body and pass it to the request as `multipart` parameter:

```ruby
api_request_context.post(
  "https://example.com/api/upload_script",
  multipart: {
    fileField: {
      name: "f.js",
      mimeType: "text/javascript",
      buffer: "console.log(2022);",
    },
  },
)
```

## put

```
def put(
      url,
      data: nil,
      failOnStatusCode: nil,
      form: nil,
      headers: nil,
      ignoreHTTPSErrors: nil,
      maxRedirects: nil,
      maxRetries: nil,
      multipart: nil,
      params: nil,
      timeout: nil)
```


Sends HTTP(S) [PUT](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/PUT) request and returns its response.
The method will populate request cookies from the context and update
context cookies from the response. The method will automatically follow redirects.
