# Group Members

## GET All group members

You can GET all group members for a particular group in `/api/v1/groups/:group_id/members`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Query Parameters

| Parameter      | Description                                    |
| -------------- | ---------------------------------------------- |
| `page[number]` | The `number`<sup>th</sup> page of the response |
| `page[size]`   | The `size` of the `per_page` response          |

### Possible exceptions

| Error Code | Description                                                      |
| ---------- | ---------------------------------------------------------------- |
| 401        | When user tries to authenticate with invalid or corrupt `token`. |
| 404        | When group has no groups members associated with it.             |

```http
GET /api/v1/groups/:group_id/members HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 200 OK
```

> JSON response example

```json
{
  "data": [
    {
      "id": "1",
      "type": "group_member",
      "attributes": {
        "group_id": 1,
        "user_id": 1,
        "created_at": "2020-02-25T18:15:52.890Z",
        "updated_at": "2020-02-25T18:15:52.890Z",
        "mentor": false,
        "name": "Test User 1",
        "email": "test@test.com"
      }
    }
  ],
  "links": {
    "self": "http://localhost:3000/api/v1/groups/1/group_members?page[number]=1",
    "first": "http://localhost:3000/api/v1/groups/1/group_members?page[number]=1",
    "prev": null,
    "next": null,
    "last": "http://localhost:3000/api/v1/groups/1/group_members?page[number]=1"
  }
}
```

## CREATE/ADD Group Member

You can add members to your group in `/api/v1/groups/:group_id/members`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter  | Description                                      |
| ---------- | ------------------------------------------------ |
| `group_id` | The `id` of the group, members are to be fetched |

<aside class="notice">emails in POST request is comma separated string of emails</aside>

### Possible exceptions

| Error Code | Description                                                        |
| ---------- | ------------------------------------------------------------------ |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.     |
| 403        | When non-primary mentor user tries to add members to the group     |
| 404        | When the requested group identified by `group_id` does not exists. |

```http
POST /api/v1/groups/:group_id/members HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```json
{
  "emails": "newuser@test.com, alreadyexists@test.com, NA"
}
```

```http
HTTP/1.1 200 OK
```

> JSON response example:

```json
{
  "added": ["alreadyexists@test.com"],
  "pending": ["newuser@test.com"],
  "invalid": ["NA"]
}
```

## DELETE Group Member

Group's primary mentor can DELETE a group member (identified by `:id`) in `/api/v1/group/members/:id/`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                                |
| --------- | ------------------------------------------ |
| `id`      | The `id` of the group member to be deleted |

<aside class="warning">User with primary mentor or admin access can only delete the group member</aside>

### Possible exceptions

| Error Code | Description                                                         |
| ---------- | ------------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.      |
| 403        | When non-primary mentor user tries to delete the group member       |
| 404        | When the requested group member identified by `id` does not exists. |

```http
DELETE /api/v1/group/members/:id HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 204 NO CONTENT
Content-Type: application/json
```

## UPDATE Group Member

Group's primary mentor can UPDATE a group member (identified by `:id`) in `/api/v1/group/members/:id/`. Authentication `token` is passed through `Authorization` header and is **required**.

### List of acceptable params for put/patch requests include:

| Name          | Type     | Description                       |
| ------------- | -------- | --------------------------------- |
| `mentor`      | `String` | Updated mentor status for member  |


### URL Parameters

| Parameter | Description                                |
| --------- | ------------------------------------------ |
| `id`      | The `id` of the group member to be updated |

<aside class="warning">User with primary mentor or admin access can only update the group member</aside>

### Possible exceptions

| Error Code | Description                                                         |
| ---------- | ------------------------------------------------------------------- |
| 400        | When invalid parameters are used                                    |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.      |
| 403        | When non-primary mentor user tries to update the group member       |
| 404        | When the requested group member identified by `id` does not exists. |

```http
PATCH /api/v1/group/members/:id HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```
```json
{
  "group_member": {
    "mentor": "true"
  }
}
```

```http
HTTP/1.1 202 ACCEPTED
Content-Type: application/json
```
