# Comments

Comments are an implementation of [commontator](https://github.com/lml/commontator) gem, refer for any unclear terms.

<aside class="notice">vote_status attribute of a comment can be "null" if user is not authenticated or one of "unvoted", "upvoted", "downvoted" based on user interaction with the comment</aside>

## CLOSE Thread

You can close currently open threads with proper access in `/api/v1/threads/:id/close`. Authentication `token` is passed through `Authorization` header and is **required**.

<aside class="warning">Only users with open/close access can close the thread</aside>

### Possible exceptions

| Error Code | Description                                                      |
| ---------- | ---------------------------------------------------------------- |
| 401        | When user tries to close thread with invalid or corrupt `token`. |
| 403        | When the user don't have access to close thread                  |
| 404        | When the thread identified by :id does not exist                 |
| 409        | When the thread identified by :id is already closed              |

```http
PUT /api/v1/threads/:id/close HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 200 OK
```

> JSON response example :

```json
{
  "message": "thread closed"
}
```

## REOPEN Thread

You can reopen currently closed threads with proper access in `/api/v1/threads/:id/reopen`. Authentication `token` is passed through `Authorization` header and is **required**.

<aside class="warning">Only users with open/close access can reopen the thread</aside>

### Possible exceptions

| Error Code | Description                                                       |
| ---------- | ----------------------------------------------------------------- |
| 401        | When user tries to reopen thread with invalid or corrupt `token`. |
| 403        | When the user don't have access to reopen thread                  |
| 404        | When the thread identified by :id does not exist                  |
| 409        | When the thread identified by :id is already opened               |

```http
PUT /api/v1/threads/:id/reopen HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 200 OK
```

> JSON response example :

```json
{
  "message": "thread reopened"
}
```

## SUBSCRIBE Thread

You can subscribe a thread with in `/api/v1/threads/:id/subscribe`. Authentication `token` is passed through `Authorization` header and is **required**.

### Possible exceptions

| Error Code | Description                                                          |
| ---------- | -------------------------------------------------------------------- |
| 401        | When user tries to subscribe thread with invalid or corrupt `token`. |
| 403        | When the user don't have access to subscribe thread                  |
| 404        | When the thread identified by :id does not exist                     |
| 409        | When the thread identified by :id is already subscribed by the user  |

```http
PUT /api/v1/threads/:id/subscribe HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 200 OK
```

> JSON response example :

```json
{
  "message": "thread subscribed"
}
```

## UNSUBSCRIBE Thread

You can unsubscribe a thread with in `/api/v1/threads/:id/unsubscribe`. Authentication `token` is passed through `Authorization` header and is **required**.

### Possible exceptions

| Error Code | Description                                                            |
| ---------- | ---------------------------------------------------------------------- |
| 401        | When user tries to unsubscribe thread with invalid or corrupt `token`. |
| 403        | When the user don't have access to unsubscribe thread                  |
| 404        | When the thread identified by :id does not exist                       |
| 409        | When the thread identified by :id is already unsubscribed by the user  |

```http
PUT /api/v1/threads/:id/unsubscribe HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 200 OK
```

> JSON response example :

```json
{
  "message": "thread unsubscribed"
}
```

## GET All Comments

You can GET all comments (paginated) for a thread in `/api/v1/threads/:id/comments`. Authentication `token` is passed through `Authorization` header and is **optional**.

### URL Query Parameters

| Parameter      | Description                                    |
| -------------- | ---------------------------------------------- |
| `page[number]` | The `number`<sup>th</sup> page of the response |
| `page[size]`   | The `size` of the `per_page` response          |

<aside class="notice">Authorization is required to fetch comments for "Non-Public" projects</aside>

<aside class="notice">"Non-Public" projects can be commented on by author himself/herself & hence the corresponding comments are only accessible to author</aside>

### Possible exceptions

| Error Code | Description                                                      |
| ---------- | ---------------------------------------------------------------- |
| 401        | When user tries to authenticate with invalid or corrupt `token`. |
| 403        | When the user don't have access to fetch thread's comments       |
| 404        | When the thread identified by :thread_id does not exist          |

```http
PUT /api/v1/threads/:id/comments HTTP/1.1
Accept: application/json
Authorization: Token {token} // optional
Host: localhost
```

```http
HTTP/1.1 200 OK
```

> JSON response example :

```json
{
  "data": [
    {
      "id": "1",
      "type": "comment",
      "attributes": {
        "creator_name": "Test User",
        "upvotes": 1,
        "downvotes": 0,
        "vote_status": null,
        "is_deleted": false,
        "has_edit_access": true,
        "has_delete_access": true,
        "creator_type": "User",
        "body": "Hi! I am a comment",
        "created_at": "2020-08-15T14:20:59.162Z",
        "updated_at": "2020-08-15T14:21:11.614Z"
      },
      "relationships": {
        "thread": {
          "data": {
            "id": "1",
            "type": "thread"
          }
        },
        "editor": {
          "data": {
            "id": "1",
            "type": "editor"
          }
        },
        "creator": {
          "data": {
            "id": "1",
            "type": "creator"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://localhost:3000/api/v1/threads/1/comments?page[number]=1",
    "first": "http://localhost:3000/api/v1/threads/1/comments?page[number]=1",
    "prev": null,
    "next": null,
    "last": "http://localhost:3000/api/v1/threads/1/comments?page[number]=1"
  }
}
```

## POST Comment

You can POST a comment in `/api/v1/threads/:thread_id/comments`. Authentication `token` is passed through `Authorization` header and is **required**.

### List of acceptable params for post request include:

| Name   | Type     | Description         |
| ------ | -------- | ------------------- |
| `body` | `String` | body of the comment |

### URL Parameters

| Parameter   | Description                                        |
| ----------- | -------------------------------------------------- |
| `thread_id` | The `id` of the thread, comment is to be added for |

### Possible exceptions

| Error Code | Description                                                          |
| ---------- | -------------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.       |
| 403        | When user don't have access to create/add comment                    |
| 404        | When the requested thread identified by `thread_id` does not exists. |
| 422        | When invalid parameters are passed.                                  |

```http
POST /api/v1/threads/:thread_id/comments HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```json
{
  "comment": {
    "body": "Hi! I am a comment"
  }
}
```

```http
HTTP/1.1 201 CREATED
Content-Type: application/json
```

> JSON response example :

```json
{
  "data": {
    "id": "1",
    "type": "comment",
    "attributes": {
      "creator_name": "Test User",
      "upvotes": 1,
      "downvotes": 0,
      "vote_status": null,
      "is_deleted": false,
      "has_edit_access": true,
      "has_delete_access": true,
      "creator_type": "User",
      "body": "Hi! I am a comment",
      "created_at": "2020-08-15T14:20:59.162Z",
      "updated_at": "2020-08-15T14:21:11.614Z"
    },
    "relationships": {
      "thread": {
        "data": {
          "id": "1",
          "type": "thread"
        }
      },
      "editor": null,
      "creator": {
        "data": {
          "id": "1",
          "type": "creator"
        }
      }
    }
  }
}
```

## UPDATE Comment

You can UPDATE a comment in `/api/v1/comments/:id`. Authentication `token` is passed through `Authorization` header and is **required**.

### List of acceptable params for put/patch request include:

| Name   | Type     | Description         |
| ------ | -------- | ------------------- |
| `body` | `String` | body of the comment |

### URL Parameters

| Parameter | Description                           |
| --------- | ------------------------------------- |
| `id`      | The `id` of the comment to be updated |

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |
| 403        | When user don't have access to update comment                  |
| 404        | When the requested comment identified by `id` does not exists. |
| 422        | When invalid parameters are passed.                            |

```http
POST /api/v1/comments/:id HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```json
{
  "comment": {
    "body": "Hi! I am updated comment"
  }
}
```

```http
HTTP/1.1 202 ACCEPTED
Content-Type: application/json
```

> JSON response example :

```json
{
  "data": {
    "id": "1",
    "type": "comment",
    "attributes": {
      "creator_name": "Test User",
      "upvotes": 1,
      "downvotes": 0,
      "vote_status": null,
      "is_deleted": false,
      "has_edit_access": true,
      "has_delete_access": true,
      "creator_type": "User",
      "body": "Hi! I am updated comment",
      "created_at": "2020-08-15T14:20:59.162Z",
      "updated_at": "2020-08-15T14:21:11.614Z"
    },
    "relationships": {
      "thread": {
        "data": {
          "id": "1",
          "type": "thread"
        }
      },
      "editor": {
        "data": {
          "id": "1",
          "type": "editor"
        }
      },
      "creator": {
        "data": {
          "id": "1",
          "type": "creator"
        }
      }
    }
  }
}
```

## DELETE Comment

Comment (identified by `:id`) can be DELETED in `/api/v1/comments/:id/deleted`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                           |
| --------- | ------------------------------------- |
| `id`      | The `id` of the comment to be deleted |

<aside class="warning">User with author or editor access can only delete the comment</aside>

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |
| 403        | When user without editor tries to delete the comment           |
| 404        | When the requested comment identified by `id` does not exists. |
| 409        | When the comment identified by :id is already deleted          |

```http
PUT /api/v1/comments/:id/delete HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 204 NO CONTENT
Content-Type: application/json
```

> JSON response example :

```json
{
  "message": "comment deleted"
}
```

## UNDELETE Comment

Comment (identified by `:id`) can be UNDELETED in `/api/v1/comments/:id/undelete`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                             |
| --------- | --------------------------------------- |
| `id`      | The `id` of the comment to be undeleted |

<aside class="warning">User with author or editor access can only undelete the comment</aside>

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |
| 403        | When user without editor tries to delete the comment           |
| 404        | When the requested comment identified by `id` does not exists. |

```http
PUT /api/v1/comments/:id/undelete HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 200 OK
Content-Type: application/json
```

> JSON response example :

```json
{
  "data": {
    "id": "1",
    "type": "comment",
    "attributes": {
      "creator_name": "Test User",
      "upvotes": 1,
      "downvotes": 0,
      "vote_status": null,
      "is_deleted": false,
      "has_edit_access": true,
      "has_delete_access": true,
      "creator_type": "User",
      "body": "Hi! I am a comment",
      "created_at": "2020-08-15T14:20:59.162Z",
      "updated_at": "2020-08-15T14:21:11.614Z"
    },
    "relationships": {
      "thread": {
        "data": {
          "id": "1",
          "type": "thread"
        }
      },
      "editor": {
        "data": {
          "id": "1",
          "type": "editor"
        }
      },
      "creator": {
        "data": {
          "id": "1",
          "type": "creator"
        }
      }
    }
  }
}
```

## UPVOTE Comment

Comment (identified by `:id`) can be UPVOTED in `/api/v1/comments/:id/upvote`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                           |
| --------- | ------------------------------------- |
| `id`      | The `id` of the comment to be upvoted |

<aside class="warning">Author cannot upvote his/her own comment</aside>

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |
| 403        | When author tries to upvote his/her comment                    |
| 404        | When the requested comment identified by `id` does not exists. |

```http
PUT /api/v1/comments/:id/upvote HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 200 OK
Content-Type: application/json
```

> JSON response example :

```json
{
  "message": "comment upvoted"
}
```

## DOWNVOTE Comment

Comment (identified by `:id`) can be DOWNVOTED in `/api/v1/comments/:id/downvote`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                           |
| --------- | ------------------------------------- |
| `id`      | The `id` of the comment to be upvoted |

<aside class="warning">Author cannot downvote his/her own comment</aside>

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |
| 403        | When author tries to downvote his/her comment                  |
| 404        | When the requested comment identified by `id` does not exists. |

```http
PUT /api/v1/comments/:id/downvote HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 200 OK
Content-Type: application/json
```

> JSON response example :

```json
{
  "message": "comment downvoted"
}
```

## UNVOTE Comment

Comment (identified by `:id`) can be UNVOTED in `/api/v1/comments/:id/unvote`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                           |
| --------- | ------------------------------------- |
| `id`      | The `id` of the comment to be upvoted |

<aside class="warning">Author cannot unvote his/her own comment</aside>

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |
| 403        | When author tries to unvote his/her comment                    |
| 404        | When the requested comment identified by `id` does not exists. |

```http
PUT /api/v1/comments/:id/unvote HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 200 OK
Content-Type: application/json
```

> JSON response example :

```json
{
  "message": "comment unvoted"
}
```
