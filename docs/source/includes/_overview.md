# Overview

Welcome to the CircuitVerse API! You can use our API to access CircuitVerse API endpoints, which can get information on various public projects, user projects, groups you mentor, pending assignments and a whole bunch of stuff.

<aside class="success">The CircuitVerse API uses json:api specs</aside>

## Client Errors

```http
HTTP/1.1 400 Bad Request
```

```json
{
  "errors": [
    {
      "status": 400,
      "title": "invalid parameters",
      "detail": "invalid parameters"
    }
  ]
}
```

```http
HTTP/1.1 422 Unprocessable Entity
```

```json
{
  "errors": [
    {
      "status": 422,
      "title": "resource invalid!",
      "detail": "resource invalid!"
    }
  ]
}
```

```http
HTTP/1.1 401 Unauthorized
```

```json
{
  "errors": [
    {
      "status": 401,
      "title": "not authenticated",
      "detail": "not authenticated"
    }
  ]
}
```

```http
HTTP/1.1 403 Forbidden
```

```json
{
  "errors": [
    {
      "status": 403,
      "title": "not authorized",
      "detail": "not authorized"
    }
  ]
}
```

```http
HTTP/1.1 500 Internal Server Error
```

```json
{
  "errors": [
    {
      "status": 500,
      "title": "Something Unexpectedly Went Wrong! Please consider opening a github issue :)",
      "detail": "Something Unexpectedly Went Wrong! Please consider opening a github issue :)"
    }
  ]
}
```

| Error Code | Meaning                                                                                   |
| ---------- | ----------------------------------------------------------------------------------------- |
| 400        | Bad Request -- Your request is invalid.                                                   |
| 401        | Unauthorized -- Your Authentication token is wrong.                                       |
| 403        | Forbidden -- The resource requested is hidden for requested user only.                    |
| 404        | Not Found -- The resource requested could not be found.                                   |
| 405        | Method Not Allowed -- You tried to access a resource with an invalid method.              |
| 409        | Conflict -- The request could not be processed due to a conflict.                         |
| 429        | Too Many Requests -- You're requesting too many resources! Slow down!                     |
| 500        | Internal Server Error -- We had a problem with our server. Try again later.               |
| 503        | Service Unavailable -- We're temporarily offline for maintenance. Please try again later. |

## Authorization

CircuitVerse API uses `RSASSA` cryptographic signing that requires `private` and associated `public` key

```http
GET /api/v1/users/1 HTTP/1.1
Accept: application/json
Host: localhost
Authorization: Token eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjp7InVzZXJfaWQiOjIsInVzZXJuYW1lIjoiTml0aXNoIEFnZ2Fyd2FsIiwiZW1haWwiOiJyb3lhbG5pdGlzaDIxQGdtYWlsLmNvbSJ9LCJleHAiOjE1ODkyMDI5ODF9.tHRLJeQGuLiJ1Ncc2tQSaNiQnbrnERKuOPERfZeNnF8
```

You can authenticate in the API by providing the user's `token` in the `Authorization` header.

## Pagination

```http
GET /api/v1/resource?page[number]=2 HTTP/1.1
Accept: application/json
Host: localhost
```

Requests that return multiple items will be paginated to 5 items by default.
You can specify further pages with the `?page[number]` parameter. For some resources, you can also set a custom page size with the `?page[size]` parameter.

## Links

```http
GET /api/v1/resources HTTP/1.1
Accept: application/json
Host: localhost
```

```http
HTTP/1.1 200 OK
```

```json
{
  "resources": [],
  "links": {
    "self": "http://localhost:3000/api/v1/resource?page[number]=1",
    "first": "http://localhost:3000/api/v1/resource?page[number]=1",
    "prev": null,
    "next": "http://localhost:3000/api/v1/resource?page[number]=2",
    "last": "http://localhost:3000/api/v1/resource?page[number]=4"
  }
}
```

In each GET request that acts upon resources, there is an extra field in the response under "links" root element.
It includes, the links to current requested page, next page, previous page, first page and the last page for resources under the given params.

## Cross Origin Resource Sharing

The API supports Cross Origin Resource Sharing (CORS) for requests from any origin.
