---
sidebar_position: 10
---

# Response


[Response](./response) class represents responses which are received by page.

## all_headers

```
def all_headers
```


An object with all the response HTTP headers associated with this response.

## body

```
def body
```


Returns the buffer with response body.

## finished

```
def finished
```


Waits for this response to finish, returns always `null`.

## frame

```
def frame
```


Returns the [Frame](./frame) that initiated this response.

## from_service_worker

```
def from_service_worker
```


Indicates whether this Response was fulfilled by a Service Worker's Fetch Handler (i.e. via [FetchEvent.respondWith](https://developer.mozilla.org/en-US/docs/Web/API/FetchEvent/respondWith)).

## headers

```
def headers
```


An object with the response HTTP headers. The header names are lower-cased.
Note that this method does not return security-related headers, including cookie-related ones.
You can use [Response#all_headers](./response#all_headers) for complete list of headers that include `cookie` information.

## headers_array

```
def headers_array
```


An array with all the request HTTP headers associated with this response. Unlike [Response#all_headers](./response#all_headers), header names are NOT lower-cased.
Headers with multiple entries, such as `Set-Cookie`, appear in the array multiple times.

## header_value

```
def header_value(name)
```


Returns the value of the header matching the name. The name is case-insensitive. If multiple headers have
the same name (except `set-cookie`), they are returned as a list separated by `, `. For `set-cookie`, the `\n` separator is used. If no headers are found, `null` is returned.

## header_values

```
def header_values(name)
```


Returns all values of the headers matching the name, for example `set-cookie`. The name is case-insensitive.

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

## request

```
def request
```


Returns the matching [Request](./request) object.

## security_details

```
def security_details
```


Returns SSL and other security information.

## server_addr

```
def server_addr
```


Returns the IP address and port of the server.

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
