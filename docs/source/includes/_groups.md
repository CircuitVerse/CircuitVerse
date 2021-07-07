# Groups

## GET All your groups

You can GET all groups you are a member of in `/api/v1/groups`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Query Parameters

| Parameter      | Description                                    |
| -------------- | ---------------------------------------------- |
| `page[number]` | The `number`<sup>th</sup> page of the response |
| `page[size]`   | The `size` of the `per_page` response          |
| `include`      | Adds passed params details in `included`       |

<aside class="notice">include query param accepts `group_members` & `assignments` in comma separated string</aside>

<aside class="success">You may include one or both of the allowed included resources and the JSON response will be formatted accordingly</aside>

### Possible exceptions

| Error Code | Description                                                      |
| ---------- | ---------------------------------------------------------------- |
| 401        | When user tries to authenticate with invalid or corrupt `token`. |
| 404        | When user has no groups associated with him/her.                 |

```http
GET /api/v1/groups?include=group_members,assignments HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 200 OK
```

> JSON response example (including `group_members` & `assignments`):

```json
{
  "data": [
    {
      "id": "1",
      "type": "group",
      "attributes": {
        "member_count": 1,
        "primary_mentor_name": "Test Primary Mentor",
        "name": "Test Group 1",
        "primary_mentor_id": 1,
        "created_at": "2020-02-25T18:15:39.825Z",
        "updated_at": "2020-02-25T18:15:39.825Z"
      },
      "relationships": {
        "group_members": {
          "data": [
            {
              "id": "1",
              "type": "group_member"
            }
          ]
        },
        "assignments": {
          "data": [
            {
              "id": "1",
              "type": "assignment"
            }
          ]
        }
      }
    },
    {
      "id": "2",
      "type": "group",
      "attributes": {
        "member_count": 1,
        "primary_mentor_name": "Test Primary Mentor",
        "name": "Test Group 2",
        "primary_mentor_id": 1,
        "created_at": "2020-02-27T11:08:54.886Z",
        "updated_at": "2020-02-27T11:08:54.886Z"
      },
      "relationships": {
        "group_members": {
          "data": [
            {
              "id": "2",
              "type": "group_member"
            },
            {
              "id": "3",
              "type": "group_member"
            }
          ]
        },
        "assignments": {
          "data": []
        }
      }
    },
    {
      "id": "3",
      "type": "group",
      "attributes": {
        "member_count": 1,
        "primary_mentor_name": "Test Primary Mentor",
        "name": "Test Group 3",
        "primary_mentor_id": 1,
        "created_at": "2020-03-13T15:14:53.948Z",
        "updated_at": "2020-03-13T15:14:53.948Z"
      },
      "relationships": {
        "group_members": {
          "data": [
            {
              "id": "4",
              "type": "group_member"
            }
          ]
        },
        "assignments": {
          "data": []
        }
      }
    },
    {
      "id": "4",
      "type": "group",
      "attributes": {
        "member_count": 1,
        "primary_mentor_name": "Test Primary Mentor",
        "name": "Test Group 4",
        "primary_mentor_id": 4,
        "created_at": "2020-03-22T12:42:04.511Z",
        "updated_at": "2020-03-22T12:42:04.511Z"
      },
      "relationships": {
        "group_members": {
          "data": [
            {
              "id": "5",
              "type": "group_member"
            }
          ]
        },
        "assignments": {
          "data": [
            {
              "id": "2",
              "type": "assignment"
            }
          ]
        }
      }
    }
  ],
  "included": [
    {
      "id": "1",
      "type": "assignment",
      "attributes": {
        "name": "Test assignment 1",
        "deadline": "2021-05-24T11:47:40.244Z",
        "description": "test description",
        "created_at": "2020-05-24T11:47:40.244Z",
        "updated_at": "2020-05-24T11:47:40.244Z",
        "status": "open",
        "has_primary_mentor_access": true,
        "current_user_project_id": null,
        "grading_scale": "no_scale",
        "grades_finalized": false,
        "restrictions": "[]"
      }
    },
    {
      "id": "2",
      "type": "assignment",
      "attributes": {
        "name": "Test assignment 2",
        "deadline": "2021-05-24T11:48:26.739Z",
        "description": "test description",
        "created_at": "2020-05-24T11:48:26.740Z",
        "updated_at": "2020-05-24T11:48:26.740Z",
        "status": "open",
        "has_primary_mentor_access": true,
        "current_user_project_id": null,
        "grading_scale": "no_scale",
        "grades_finalized": false,
        "restrictions": "[]"
      }
    },
    {
      "id": "1",
      "type": "group_member",
      "attributes": {
        "group_id": 1,
        "user_id": 1,
        "created_at": "2020-02-25T18:15:52.890Z",
        "updated_at": "2020-02-25T18:15:52.890Z",
        "name": "Test User 1",
        "email": "test@test1.com"
      }
    },
    {
      "id": "2",
      "type": "group_member",
      "attributes": {
        "group_id": 2,
        "user_id": 2,
        "created_at": "2020-02-25T18:15:52.890Z",
        "updated_at": "2020-02-25T18:15:52.890Z",
        "name": "Test User 2",
        "email": "test@test2.com"
      }
    },
    {
      "id": "3",
      "type": "group_member",
      "attributes": {
        "group_id": 2,
        "user_id": 3,
        "created_at": "2020-02-25T18:15:52.890Z",
        "updated_at": "2020-02-25T18:15:52.890Z",
        "name": "Test User 3",
        "email": "test@test3.com"
      }
    },
    {
      "id": "4",
      "type": "group_member",
      "attributes": {
        "group_id": 3,
        "user_id": 4,
        "created_at": "2020-02-25T18:15:52.890Z",
        "updated_at": "2020-02-25T18:15:52.890Z",
        "name": "Test User 4",
        "email": "test@test4.com"
      }
    },
    {
      "id": "5",
      "type": "group_member",
      "attributes": {
        "group_id": 4,
        "user_id": 5,
        "created_at": "2020-02-25T18:15:52.890Z",
        "updated_at": "2020-02-25T18:15:52.890Z",
        "name": "Test User 5",
        "email": "test@test5.com"
      }
    }
  ],
  "links": {
    "self": "http://localhost:3000/api/v1/groups?page[number]=1",
    "first": "http://localhost:3000/api/v1/groups?page[number]=1",
    "prev": null,
    "next": null,
    "last": "http://localhost:3000/api/v1/groups?page[number]=1"
  }
}
```

## GET All owned groups

You can GET all groups that you are a primary mentor of in `/api/v1/groups/owned`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Query Parameters

| Parameter      | Description                                    |
| -------------- | ---------------------------------------------- |
| `page[number]` | The `number`<sup>th</sup> page of the response |
| `page[size]`   | The `size` of the `per_page` response          |
| `include`      | Adds passed params details in `included`       |

<aside class="notice">include query param accepts `group_members` & `assignments` in comma separated string</aside>

<aside class="success">You may include one or both of the allowed included resources and the JSON response will be formatted accordingly</aside>

### Possible exceptions

| Error Code | Description                                                      |
| ---------- | ---------------------------------------------------------------- |
| 401        | When user tries to authenticate with invalid or corrupt `token`. |
| 404        | When user has no groups associated with him/her.                 |

```http
GET /api/v1/groups/owned?include=group_members,assignments HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 200 OK
```

> JSON response will be similiar as above

## GET Group Details

You can GET group details (identified by `:id`) in `/api/v1/groups/:id/`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                            |
| --------- | -------------------------------------- |
| `id`      | The `id` of the project to be detailed |

<aside class="notice">group_members & assignments details in the included section</aside>

### Possible exceptions

| Error Code | Description                                                     |
| ---------- | --------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.  |
| 403        | When authenticated user is neither mentor nor user of the Group |
| 404        | When the requested group identified by `id` does not exists.    |

```http
GET /api/v1/groups/:id?include=group_members,assignments HTTP/1.1
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
    "type": "group",
    "attributes": {
      "member_count": 1,
      "primary_mentor_name": "Test Primary Mentor",
      "name": "Test Group 1",
      "primary_mentor_id": 1,
      "created_at": "2020-02-25T18:15:39.825Z",
      "updated_at": "2020-02-25T18:15:39.825Z"
    },
    "relationships": {
      "group_members": {
        "data": [
          {
            "id": "1",
            "type": "group_member"
          }
        ]
      },
      "assignments": {
        "data": [
          {
            "id": "1",
            "type": "assignment"
          }
        ]
      }
    }
  },
  "included": [
    {
      "id": "1",
      "type": "assignment",
      "attributes": {
        "name": "Test assignment 1",
        "deadline": "2021-05-24T11:47:40.244Z",
        "description": "test description",
        "created_at": "2020-05-24T11:47:40.244Z",
        "updated_at": "2020-05-24T11:47:40.244Z",
        "status": "open",
        "has_primary_mentor_access": true,
        "current_user_project_id": null,
        "grading_scale": "no_scale",
        "grades_finalized": false,
        "restrictions": "[]"
      }
    },
    {
      "id": "1",
      "type": "group_member",
      "attributes": {
        "group_id": 1,
        "user_id": 1,
        "created_at": "2020-02-25T18:15:52.890Z",
        "updated_at": "2020-02-25T18:15:52.890Z",
        "name": "Test User 1",
        "email": "test@test1.com"
      }
    }
  ]
}
```

## UPDATE Group

You can UPDATE group details (identified by `:id`) in `/api/v1/groups/:id/`. Authentication `token` is passed through `Authorization` header and is **required**.

### List of acceptable params for put/patch requests include:

| Name                | Type     | Description                       |
| ------------------- | -------- | --------------------------------- |
| `name`              | `String` | Updated name of the group         |
| `primary_mentor_id` | `String` | Primary Mentor identified by id   |

### URL Parameters

| Parameter | Description                         |
| --------- | ----------------------------------- |
| `id`      | The `id` of the group to be updated |

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 400        | When invalid parameters are used.                              |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |
| 403        | When non-primary mentor user tries to update the group         |
| 404        | When the requested group identified by `id` does not exists.   |

```http
PATCH /api/v1/groups/:id HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```json
{
  "group": {
    "name": "Group Name Updated"
    // other params here too
  }
}
```

```http
HTTP/1.1 202 ACCEPTED
Content-Type: application/json
```

> JSON response example:

```json
{
  "data": {
    "id": "1",
    "type": "group",
    "attributes": {
      "member_count": 1,
      "primary_mentor_name": "Test Primary Mentor",
      "name": "Group Name Updated",
      "primary_mentor_id": 1,
      "created_at": "2020-02-25T18:15:39.825Z",
      "updated_at": "2020-02-25T18:15:39.825Z"
    },
    "relationships": {
      "group_members": {
        "data": [
          {
            "id": "1",
            "type": "group_member"
          }
        ]
      },
      "assignments": {
        "data": [
          {
            "id": "1",
            "type": "assignment"
          }
        ]
      }
    }
  },
  "included": [
    {
      "id": "1",
      "type": "assignment",
      "attributes": {
        "name": "Test assignment 1",
        "deadline": "2021-05-24T11:47:40.244Z",
        "description": "test description",
        "created_at": "2020-05-24T11:47:40.244Z",
        "updated_at": "2020-05-24T11:47:40.244Z",
        "status": "open",
        "has_primary_mentor_access": true,
        "current_user_project_id": null,
        "grading_scale": "no_scale",
        "grades_finalized": false,
        "restrictions": "[]"
      }
    },
    {
      "id": "1",
      "type": "group_member",
      "attributes": {
        "group_id": 1,
        "user_id": 1,
        "created_at": "2020-02-25T18:15:52.890Z",
        "updated_at": "2020-02-25T18:15:52.890Z",
        "name": "Test User 1",
        "email": "test@test1.com"
      }
    }
  ]
}
```

## DELETE Group

Group's primary mentor can DELETE a group (identified by `:id`) in `/api/v1/groups/:id/`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                         |
| --------- | ----------------------------------- |
| `id`      | The `id` of the group to be deleted |

<aside class="warning">User with primary mentor or admin access can only delete the group</aside>

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |
| 403        | When non-primary mentor user tries to update the group         |
| 404        | When the requested group identified by `id` does not exists.   |

```http
DELETE /api/v1/groups/:id HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 204 NO CONTENT
Content-Type: application/json
```
