module Playwright
  #
  # `Response` class represents responses which are received by page.
  class Response < PlaywrightApi

    #
    # An object with all the response HTTP headers associated with this response.
    def all_headers
      wrap_impl(@impl.all_headers)
    end

    #
    # Returns the buffer with response body.
    def body
      wrap_impl(@impl.body)
    end

    #
    # Waits for this response to finish, returns always `null`.
    def finished
      wrap_impl(@impl.finished)
    end

    #
    # Returns the `Frame` that initiated this response.
    def frame
      wrap_impl(@impl.frame)
    end

    #
    # Indicates whether this Response was fulfilled by a Service Worker's Fetch Handler (i.e. via [FetchEvent.respondWith](https://developer.mozilla.org/en-US/docs/Web/API/FetchEvent/respondWith)).
    def from_service_worker
      wrap_impl(@impl.from_service_worker)
    end

    #
    # An object with the response HTTP headers. The header names are lower-cased.
    # Note that this method does not return security-related headers, including cookie-related ones.
    # You can use [`method: Response.allHeaders`] for complete list of headers that include `cookie` information.
    def headers
      wrap_impl(@impl.headers)
    end

    #
    # An array with all the request HTTP headers associated with this response. Unlike [`method: Response.allHeaders`], header names are NOT lower-cased.
    # Headers with multiple entries, such as `Set-Cookie`, appear in the array multiple times.
    def headers_array
      wrap_impl(@impl.headers_array)
    end

    #
    # Returns the value of the header matching the name. The name is case-insensitive. If multiple headers have
    # the same name (except `set-cookie`), they are returned as a list separated by `, `. For `set-cookie`, the `\n` separator is used. If no headers are found, `null` is returned.
    def header_value(name)
      wrap_impl(@impl.header_value(unwrap_impl(name)))
    end

    #
    # Returns all values of the headers matching the name, for example `set-cookie`. The name is case-insensitive.
    def header_values(name)
      wrap_impl(@impl.header_values(unwrap_impl(name)))
    end

    #
    # Returns the JSON representation of response body.
    #
    # This method will throw if the response body is not parsable via `JSON.parse`.
    def json
      wrap_impl(@impl.json)
    end

    #
    # Contains a boolean stating whether the response was successful (status in the range 200-299) or not.
    def ok
      wrap_impl(@impl.ok)
    end

    #
    # Returns the matching `Request` object.
    def request
      wrap_impl(@impl.request)
    end

    #
    # Returns SSL and other security information.
    def security_details
      wrap_impl(@impl.security_details)
    end

    #
    # Returns the IP address and port of the server.
    def server_addr
      wrap_impl(@impl.server_addr)
    end

    #
    # Contains the status code of the response (e.g., 200 for a success).
    def status
      wrap_impl(@impl.status)
    end

    #
    # Contains the status text of the response (e.g. usually an "OK" for a success).
    def status_text
      wrap_impl(@impl.status_text)
    end

    #
    # Returns the text representation of response body.
    def text
      wrap_impl(@impl.text)
    end

    #
    # Contains the URL of the response.
    def url
      wrap_impl(@impl.url)
    end

    # @nodoc
    def ok?
      wrap_impl(@impl.ok?)
    end

    # @nodoc
    def from_service_worker?
      wrap_impl(@impl.from_service_worker?)
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
