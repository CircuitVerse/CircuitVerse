# Users

## Get All Users

You can GET all users in `/api/v1/users`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter      | Description                                    |
| -------------- | ---------------------------------------------- |
| `page[number]` | The `number`<sup>th</sup> page of the response |
| `page[size]`   | The `size` of the `per_page` response          |

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |

```http
GET /api/v1/users HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 200 OK
```

> JSON response example:

```json
{
  "data": [
    {
      "id": "1",
      "type": "users",
      "attributes": {
        "name": "Test User 1"
      }
    },
    {
      "id": "2",
      "type": "users",
      "attributes": {
        "name": "Test User 2"
      }
    },
    {
      "id": "3",
      "type": "users",
      "attributes": {
        "name": "Test User 3"
      }
    },
    {
      "id": "4",
      "type": "users",
      "attributes": {
        "name": "Test User 4"
      }
    },
    {
      "id": "5",
      "type": "users",
      "attributes": {
        "name": "Test User 5"
      }
    }
  ],
  "links": {
    "self": "http://localhost:3000/api/v1/users?page[number]=1",
    "first": "http://localhost:3000/api/v1/users?page[number]=1",
    "prev": null,
    "next": "http://localhost:3000/api/v1/users?page[number]=2",
    "last": "http://localhost:3000/api/v1/users?page[number]=4"
  }
}
```

## GET logged in User

You can GET the logged in user details in `/api/v1/me`. Authentication `token` is passed through `Authorization` header and is **required**.

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |

```http
GET /api/v1/users/1 HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 200 OK
```

> JSON response example:

```json
{
  "data": {
    "id": "1",
    "type": "user",
    "attributes": {
      "id": 1,
      "email": "test@test1.com",
      "name": "Test User 1",
      "admin": false,
      "country": null,
      "educational_institute": null,
      "subscribed": true,
      "created_at": "2020-03-22T12:41:28.931Z",
      "updated_at": "2020-03-22T12:41:29.803Z"
    }
  }
}
```

## GET a Specific User

You can GET particular user details in `/api/v1/users/{:id}`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                      |
| --------- | -------------------------------- |
| `id`      | The `id` of the user to retrieve |

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |
| 404        | When the requested user identified by `id` does not exists.    |

```http
GET /api/v1/users/1 HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 200 OK
```

> JSON response example:

```json
{
  "data": {
    "id": "1",
    "type": "user",
    "attributes": {
      "id": 1,
      "email": "test@test1.com",
      "name": "Test User 1",
      "admin": false,
      "country": null,
      "educational_institute": null,
      "subscribed": true,
      "created_at": "2020-03-22T12:41:28.931Z",
      "updated_at": "2020-03-22T12:41:29.803Z"
    }
  }
}
```

<aside class="notice">email is serialized only if you are authorized as user associated with {:id}</aside>

## UPDATE a Specific User

You can UPDATE a specific user details in `/api/v1/users/{:id}`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                    |
| --------- | ------------------------------ |
| `id`      | The `id` of the user to update |

### Possible exceptions

| Error Code | Description                                                        |
| ---------- | ------------------------------------------------------------------ |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.     |
| 403        | When the user identified by `id` differs from `authenticated user` |
| 404        | When the user identified by `id` does not exists.                  |

```http
PATCH /api/v1/users/1 HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```json
{
  "name": "Test User 1 updated"
}
```

```http
HTTP/1.1 202 ACCEPTED
```

> JSON response example:

```json
{
  "data": {
    "id": "1",
    "type": "user",
    "attributes": {
      "id": 1,
      "email": "test@test1.com",
      "name": "Test User 1 updated",
      "admin": false,
      "country": null,
      "educational_institute": null,
      "subscribed": true,
      "created_at": "2020-03-22T12:41:28.931Z",
      "updated_at": "2020-03-22T12:41:29.803Z"
    }
  }
}
```
