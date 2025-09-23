module Playwright
  #
  # This API is used for the Web API testing. You can use it to trigger API endpoints, configure micro-services, prepare
  # environment or the service to your e2e test.
  #
  # Each Playwright browser context has associated with it `APIRequestContext` instance which shares cookie storage with
  # the browser context and can be accessed via [`property: BrowserContext.request`] or [`property: Page.request`].
  # It is also possible to create a new APIRequestContext instance manually by calling [`method: APIRequest.newContext`].
  #
  # **Cookie management**
  #
  # `APIRequestContext` returned by [`property: BrowserContext.request`] and [`property: Page.request`] shares cookie
  # storage with the corresponding `BrowserContext`. Each API request will have `Cookie` header populated with the
  # values from the browser context. If the API response contains `Set-Cookie` header it will automatically update
  # `BrowserContext` cookies and requests made from the page will pick them up. This means that if you log in using
  # this API, your e2e test will be logged in and vice versa.
  #
  # If you want API requests to not interfere with the browser cookies you should create a new `APIRequestContext` by
  # calling [`method: APIRequest.newContext`]. Such `APIRequestContext` object will have its own isolated cookie
  # storage.
  #
  # ```python sync
  # import os
  # from playwright.sync_api import sync_playwright
  #
  # REPO = "test-repo-1"
  # USER = "github-username"
  # API_TOKEN = os.getenv("GITHUB_API_TOKEN")
  #
  # with sync_playwright() as p:
  #     # This will launch a new browser, create a context and page. When making HTTP
  #     # requests with the internal APIRequestContext (e.g. `context.request` or `page.request`)
  #     # it will automatically set the cookies to the browser page and vice versa.
  #     browser = p.chromium.launch()
  #     context = browser.new_context(base_url="https://api.github.com")
  #     api_request_context = context.request
  #     page = context.new_page()
  #
  #     # Alternatively you can create a APIRequestContext manually without having a browser context attached:
  #     # api_request_context = p.request.new_context(base_url="https://api.github.com")
  #
  #
  #     # Create a repository.
  #     response = api_request_context.post(
  #         "/user/repos",
  #         headers={
  #             "Accept": "application/vnd.github.v3+json",
  #             # Add GitHub personal access token.
  #             "Authorization": f"token {API_TOKEN}",
  #         },
  #         data={"name": REPO},
  #     )
  #     assert response.ok
  #     assert response.json()["name"] == REPO
  #
  #     # Delete a repository.
  #     response = api_request_context.delete(
  #         f"/repos/{USER}/{REPO}",
  #         headers={
  #             "Accept": "application/vnd.github.v3+json",
  #             # Add GitHub personal access token.
  #             "Authorization": f"token {API_TOKEN}",
  #         },
  #     )
  #     assert response.ok
  #     assert await response.body() == '{"status": "ok"}'
  # ```
  class APIRequestContext < PlaywrightApi

    #
    # Sends HTTP(S) [DELETE](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/DELETE) request and returns its response.
    # The method will populate request cookies from the context and update
    # context cookies from the response. The method will automatically follow redirects.
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
      wrap_impl(@impl.delete(unwrap_impl(url), data: unwrap_impl(data), failOnStatusCode: unwrap_impl(failOnStatusCode), form: unwrap_impl(form), headers: unwrap_impl(headers), ignoreHTTPSErrors: unwrap_impl(ignoreHTTPSErrors), maxRedirects: unwrap_impl(maxRedirects), maxRetries: unwrap_impl(maxRetries), multipart: unwrap_impl(multipart), params: unwrap_impl(params), timeout: unwrap_impl(timeout)))
    end

    #
    # All responses returned by [`method: APIRequestContext.get`] and similar methods are stored in the memory, so that you can later call [`method: APIResponse.body`].This method discards all its resources, calling any method on disposed `APIRequestContext` will throw an exception.
    def dispose(reason: nil)
      wrap_impl(@impl.dispose(reason: unwrap_impl(reason)))
    end

    #
    # Sends HTTP(S) request and returns its response. The method will populate request cookies from the context and update
    # context cookies from the response. The method will automatically follow redirects.
    #
    # **Usage**
    #
    # JSON objects can be passed directly to the request:
    #
    # ```python
    # data = {
    #     "title": "Book Title",
    #     "body": "John Doe",
    # }
    # api_request_context.fetch("https://example.com/api/createBook", method="post", data=data)
    # ```
    #
    # The common way to send file(s) in the body of a request is to upload them as form fields with `multipart/form-data` encoding, by specifiying the `multipart` parameter:
    #
    # ```python
    # api_request_context.fetch(
    #   "https://example.com/api/uploadScript",  method="post",
    #   multipart={
    #     "fileField": {
    #       "name": "f.js",
    #       "mimeType": "text/javascript",
    #       "buffer": b"console.log(2022);",
    #     },
    #   })
    # ```
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
      wrap_impl(@impl.fetch(unwrap_impl(urlOrRequest), data: unwrap_impl(data), failOnStatusCode: unwrap_impl(failOnStatusCode), form: unwrap_impl(form), headers: unwrap_impl(headers), ignoreHTTPSErrors: unwrap_impl(ignoreHTTPSErrors), maxRedirects: unwrap_impl(maxRedirects), maxRetries: unwrap_impl(maxRetries), method: unwrap_impl(method), multipart: unwrap_impl(multipart), params: unwrap_impl(params), timeout: unwrap_impl(timeout)))
    end

    #
    # Sends HTTP(S) [GET](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/GET) request and returns its response.
    # The method will populate request cookies from the context and update
    # context cookies from the response. The method will automatically follow redirects.
    #
    # **Usage**
    #
    # Request parameters can be configured with `params` option, they will be serialized into the URL search parameters:
    #
    # ```python
    # query_params = {
    #   "isbn": "1234",
    #   "page": "23"
    # }
    # api_request_context.get("https://example.com/api/getText", params=query_params)
    # ```
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
      wrap_impl(@impl.get(unwrap_impl(url), data: unwrap_impl(data), failOnStatusCode: unwrap_impl(failOnStatusCode), form: unwrap_impl(form), headers: unwrap_impl(headers), ignoreHTTPSErrors: unwrap_impl(ignoreHTTPSErrors), maxRedirects: unwrap_impl(maxRedirects), maxRetries: unwrap_impl(maxRetries), multipart: unwrap_impl(multipart), params: unwrap_impl(params), timeout: unwrap_impl(timeout)))
    end

    #
    # Sends HTTP(S) [HEAD](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/HEAD) request and returns its response.
    # The method will populate request cookies from the context and update
    # context cookies from the response. The method will automatically follow redirects.
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
      wrap_impl(@impl.head(unwrap_impl(url), data: unwrap_impl(data), failOnStatusCode: unwrap_impl(failOnStatusCode), form: unwrap_impl(form), headers: unwrap_impl(headers), ignoreHTTPSErrors: unwrap_impl(ignoreHTTPSErrors), maxRedirects: unwrap_impl(maxRedirects), maxRetries: unwrap_impl(maxRetries), multipart: unwrap_impl(multipart), params: unwrap_impl(params), timeout: unwrap_impl(timeout)))
    end

    #
    # Sends HTTP(S) [PATCH](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/PATCH) request and returns its response.
    # The method will populate request cookies from the context and update
    # context cookies from the response. The method will automatically follow redirects.
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
      wrap_impl(@impl.patch(unwrap_impl(url), data: unwrap_impl(data), failOnStatusCode: unwrap_impl(failOnStatusCode), form: unwrap_impl(form), headers: unwrap_impl(headers), ignoreHTTPSErrors: unwrap_impl(ignoreHTTPSErrors), maxRedirects: unwrap_impl(maxRedirects), maxRetries: unwrap_impl(maxRetries), multipart: unwrap_impl(multipart), params: unwrap_impl(params), timeout: unwrap_impl(timeout)))
    end

    #
    # Sends HTTP(S) [POST](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/POST) request and returns its response.
    # The method will populate request cookies from the context and update
    # context cookies from the response. The method will automatically follow redirects.
    #
    # **Usage**
    #
    # JSON objects can be passed directly to the request:
    #
    # ```python
    # data = {
    #     "title": "Book Title",
    #     "body": "John Doe",
    # }
    # api_request_context.post("https://example.com/api/createBook", data=data)
    # ```
    #
    # To send form data to the server use `form` option. Its value will be encoded into the request body with `application/x-www-form-urlencoded` encoding (see below how to use `multipart/form-data` form encoding to send files):
    #
    # ```python
    # formData = {
    #     "title": "Book Title",
    #     "body": "John Doe",
    # }
    # api_request_context.post("https://example.com/api/findBook", form=formData)
    # ```
    #
    # The common way to send file(s) in the body of a request is to upload them as form fields with `multipart/form-data` encoding. Use `FormData` to construct request body and pass it to the request as `multipart` parameter:
    #
    # ```python
    # api_request_context.post(
    #   "https://example.com/api/uploadScript'",
    #   multipart={
    #     "fileField": {
    #       "name": "f.js",
    #       "mimeType": "text/javascript",
    #       "buffer": b"console.log(2022);",
    #     },
    #   })
    # ```
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
      wrap_impl(@impl.post(unwrap_impl(url), data: unwrap_impl(data), failOnStatusCode: unwrap_impl(failOnStatusCode), form: unwrap_impl(form), headers: unwrap_impl(headers), ignoreHTTPSErrors: unwrap_impl(ignoreHTTPSErrors), maxRedirects: unwrap_impl(maxRedirects), maxRetries: unwrap_impl(maxRetries), multipart: unwrap_impl(multipart), params: unwrap_impl(params), timeout: unwrap_impl(timeout)))
    end

    #
    # Sends HTTP(S) [PUT](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/PUT) request and returns its response.
    # The method will populate request cookies from the context and update
    # context cookies from the response. The method will automatically follow redirects.
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
      wrap_impl(@impl.put(unwrap_impl(url), data: unwrap_impl(data), failOnStatusCode: unwrap_impl(failOnStatusCode), form: unwrap_impl(form), headers: unwrap_impl(headers), ignoreHTTPSErrors: unwrap_impl(ignoreHTTPSErrors), maxRedirects: unwrap_impl(maxRedirects), maxRetries: unwrap_impl(maxRetries), multipart: unwrap_impl(multipart), params: unwrap_impl(params), timeout: unwrap_impl(timeout)))
    end

    #
    # Returns storage state for this request context, contains current cookies and local storage snapshot if it was passed to the constructor.
    def storage_state(indexedDB: nil, path: nil)
      raise NotImplementedError.new('storage_state is not implemented yet.')
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def once(event, callback)
      event_emitter_proxy.once(event, callback)
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def on(event, callback)
      event_emitter_proxy.on(event, callback)
    end

    # -- inherited from EventEmitter --
    # @nodoc
    def off(event, callback)
      event_emitter_proxy.off(event, callback)
    end

    private def event_emitter_proxy
      @event_emitter_proxy ||= EventEmitterProxy.new(self, @impl)
    end
  end
end
