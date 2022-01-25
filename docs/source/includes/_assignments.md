# Assignments

## GET Group's Assignments

You can GET all the assignments for the group you have access to in `/api/v1/groups/:group_id/assignments`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Query Parameters

| Parameter      | Description                                    |
| -------------- | ---------------------------------------------- |
| `page[number]` | The `number`<sup>th</sup> page of the response |
| `page[size]`   | The `size` of the `per_page` response          |
| `include`      | Adds passed params details in `included`       |

<aside class="notice">include query param accepts `grades` & `projects` in comma separated string</aside>

<aside class="warning">Only users with show access can fetch the assignments</aside>

### Possible exceptions

| Error Code | Description                                                      |
| ---------- | ---------------------------------------------------------------- |
| 401        | When user tries to authenticate with invalid or corrupt `token`. |
| 403        | When user without show access tries to fetch assignments         |
| 404        | When the group identified by :group_id does not exist            |

```http
GET /api/v1/groups/:group_id/assignments?include=grades,projects HTTP/1.1
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
  "data": [
    {
      "id": "1",
      "type": "assignment",
      "attributes": {
        "name": "Test assignment 1",
        "deadline": "2021-05-24T11:47:40.244Z",
        "description": "assignment description",
        "created_at": "2020-05-24T11:47:40.244Z",
        "updated_at": "2020-05-24T11:47:40.244Z",
        "status": "open",
        "restrictions": "[\"Input\",\"ConstantVal\",\"Splitter\",\"Random\"]",
        "has_mentor_access": true,
        "current_user_project_id": null,
        "grading_scale": "no_scale",
        "grades_finalized": false
      },
      "relationships": {
        "projects": {
          "data": [
            {
              "id": "1",
              "type": "project"
            }
          ]
        },
        "grades": {
          "data": [
            {
              "id": "1",
              "type": "grade"
            }
          ]
        }
      }
    },
    {
      "id": "2",
      "type": "assignment",
      "attributes": {
        "name": "Test assignment 2",
        "deadline": "2021-05-24T11:47:40.244Z",
        "description": "assignment description",
        "created_at": "2020-05-24T11:47:40.244Z",
        "updated_at": "2020-05-24T11:47:40.244Z",
        "status": "open",
        "restrictions": "[\"Input\",\"ConstantVal\",\"Splitter\",\"Random\"]",
        "has_mentor_access": true,
        "current_user_project_id": null,
        "grading_scale": "no_scale",
        "grades_finalized": false
      },
      "relationships": {
        "projects": {
          "data": [
            {
              "id": "2",
              "type": "project"
            }
          ]
        },
        "grades": {
          "data": [
            {
              "id": "2",
              "type": "grade"
            }
          ]
        }
      }
    }
  ],
  "included": [
    {
      "id": "1",
      "type": "grade",
      "attributes": {
        "grade": "A",
        "remarks": null,
        "created_at": "2020-06-25T13:37:51.049Z",
        "updated_at": "2020-06-25T13:37:51.049Z"
      },
      "relationships": {
        "project": {
          "data": {
            "id": "1",
            "type": "project"
          }
        }
      }
    },
    {
      "id": "1",
      "type": "project",
      "attributes": {
        "name": "Test User 1/Test Project 1",
        "project_access_type": "Private",
        "created_at": "2020-06-12T08:19:05.139Z",
        "updated_at": "2020-06-12T08:19:05.139Z",
        "image_preview": {
          "url": "/img/default.png"
        },
        "description": null,
        "view": 1,
        "tags": [],
        "author_name": "Test User 1",
        "stars_count": 0
      },
      "relationships": {
        "author": {
          "data": {
            "id": "1",
            "type": "author"
          }
        }
      }
    },
    {
      "id": "2",
      "type": "grade",
      "attributes": {
        "grade": "A",
        "remarks": null,
        "created_at": "2020-06-25T13:37:51.049Z",
        "updated_at": "2020-06-25T13:37:51.049Z"
      },
      "relationships": {
        "project": {
          "data": {
            "id": "2",
            "type": "project"
          }
        }
      }
    },
    {
      "id": "2",
      "type": "project",
      "attributes": {
        "name": "Test User 2/Test Project 2",
        "project_access_type": "Private",
        "created_at": "2020-06-12T08:19:05.139Z",
        "updated_at": "2020-06-12T08:19:05.139Z",
        "image_preview": {
          "url": "/img/default.png"
        },
        "description": null,
        "view": 1,
        "tags": [],
        "author_name": "Test User 2",
        "stars_count": 0
      },
      "relationships": {
        "author": {
          "data": {
            "id": "2",
            "type": "author"
          }
        }
      }
    }
  ],
  "links": {
    "self": "http://localhost:3000/api/v1/groups/1/assignments?page[number]=1",
    "first": "http://localhost:3000/api/v1/groups/1/assignments?page[number]=1",
    "prev": null,
    "next": null,
    "last": "http://localhost:3000/api/v1/groups/1/assignments?page[number]=1"
  }
}
```

## GET Assignment details

You can GET assignment details (identified by `:id`) in `/api/v1/assignments/:id/`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                               |
| --------- | ----------------------------------------- |
| `id`      | The `id` of the assignment to be detailed |

### URL Query Paramters

| Parameter | Description                              |
| --------- | ---------------------------------------- |
| `include` | Adds passed params details in `included` |

<aside class="notice">include query param accepts `grades` & `projects` in comma separated string</aside>

### Possible exceptions

| Error Code | Description                                                       |
| ---------- | ----------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.    |
| 403        | When authenticated user is neither mentor nor user of the Group   |
| 404        | When the requested assignment identified by `id` does not exists. |

```http
GET /api/v1/assignments/:id?include=grades,projects HTTP/1.1
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
    "type": "assignment",
    "attributes": {
      "name": "Test assignment 1",
      "deadline": "2021-05-24T11:47:40.244Z",
      "description": "assignment description",
      "created_at": "2020-05-24T11:47:40.244Z",
      "updated_at": "2020-05-24T11:47:40.244Z",
      "status": "open",
      "restrictions": "[\"Input\",\"ConstantVal\",\"Splitter\",\"Random\"]",
      "has_mentor_access": true,
      "current_user_project_id": null,
      "grading_scale": "no_scale",
      "grades_finalized": false
    },
    "relationships": {
      "projects": {
        "data": [
          {
            "id": "1",
            "type": "project"
          }
        ]
      },
      "grades": {
        "data": [
          {
            "id": "1",
            "type": "grade"
          }
        ]
      }
    },
    "included": [
      {
        "id": "1",
        "type": "grade",
        "attributes": {
          "grade": "A",
          "remarks": null,
          "created_at": "2020-06-25T13:37:51.049Z",
          "updated_at": "2020-06-25T13:37:51.049Z"
        },
        "relationships": {
          "project": {
            "data": {
              "id": "1",
              "type": "project"
            }
          }
        }
      },
      {
        "id": "1",
        "type": "project",
        "attributes": {
          "name": "Test User 1/Project 1",
          "project_access_type": "Private",
          "created_at": "2020-06-12T08:19:05.139Z",
          "updated_at": "2020-06-12T08:19:05.139Z",
          "image_preview": {
            "url": "/img/default.png"
          },
          "description": null,
          "view": 1,
          "tags": [],
          "author_name": "Test User 1",
          "stars_count": 0
        },
        "relationships": {
          "author": {
            "data": {
              "id": "2",
              "type": "author"
            }
          }
        }
      }
    ]
  }
}
```

## POST Assignment

You can POST assignment in `/api/v1/groups/:group_id/assignments`. Authentication `token` is passed through `Authorization` header and is **required**.

### List of acceptable params for post request include:

| Name            | Type                 | Description                                 |
| --------------- | -------------------- | ------------------------------------------- |
| `name`          | `String`             | Name of the Assignment                      |
| `deadline`      | `String`             | Updated name of the group                   |
| `description`   | `String`             | Description of the assignment               |
| `grading_scale` | `String`             | grading scale for the assignment            |
| `restrictions`  | `JSON encoded array` | restrictions for assignments in json string |

### URL Parameters

| Parameter  | Description                                      |
| ---------- | ------------------------------------------------ |
| `group_id` | The `id` of the group, assignment is to be added |

### URL Query Paramters

| Parameter | Description                              |
| --------- | ---------------------------------------- |
| `include` | Adds passed params details in `included` |

<aside class="notice">include query param accepts `grades` & `projects` in comma separated string</aside>

<aside class="warning">The grading_scale cannot be changed later on</aside>

### Possible exceptions

| Error Code | Description                                                        |
| ---------- | ------------------------------------------------------------------ |
| 400        | When invalid parameters are used.                                  |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.     |
| 403        | When non-mentor user tries to add the assignment                   |
| 404        | When the requested group identified by `group_id` does not exists. |

```http
POST /api/v1/groups/:group_id/assignments HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```json
{
  "name": "Test assignment",
  "deadline": "date_time_string",
  "description": "Test description",
  "grading_scale": "letter",
  "restrictions": "[\"Input\",\"ConstantVal\",\"Splitter\",\"Random\"]"
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
    "type": "assignment",
    "attributes": {
      "name": "Test Assignment",
      "deadline": "2020-06-18T18:00:00.000Z",
      "description": "",
      "status": "open",
      "restrictions": "[\"Input\",\"ConstantVal\",\"Splitter\",\"Random\"]",
      "has_mentor_access": true,
      "current_user_project_id": null,
      "created_at": "2020-06-11T10:34:55.009Z",
      "updated_at": "2020-06-25T16:55:42.317Z",
      "grading_scale": "letter",
      "grades_finalized": false
    },
    "relationships": {
      "projects": {
        "data": []
      },
      "grades": {
        "data": []
      }
    }
  }
}
```

## UPDATE Assignment

You can PATCH assignment details in `/api/v1/assignments/:id`. Authentication `token` is passed through `Authorization` header and is **required**.

### List of acceptable params for put/patch request include:

| Name           | Type          | Description                                 |
| -------------- | ------------- | ------------------------------------------- |
| `name`         | `String`      | Name of the Assignment                      |
| `deadline`     | `String`      | Updated name of the group                   |
| `description`  | `String`      | Description of the assignment               |
| `restrictions` | `JSON String` | restrictions for assignments in json string |

### URL Parameters

| Parameter | Description                              |
| --------- | ---------------------------------------- |
| `id`      | The `id` of the assignment to be updated |

### Possible exceptions

| Error Code | Description                                                       |
| ---------- | ----------------------------------------------------------------- |
| 400        | When invalid parameters are used.                                 |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.    |
| 403        | When non-mentor user tries to update the assignment               |
| 404        | When the requested assignment identified by `id` does not exists. |

```http
PATCH /api/v1/assignments/:id HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```json
{
  "name": "Test assignment Updated",
  "deadline": "date_time_string",
  "description": "Test description",
  "restrictions": "[\"Input\",\"Splitter\",\"Random\"]"
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
    "type": "assignment",
    "attributes": {
      "name": "Test Assignment Updated",
      "deadline": "2020-06-18T18:00:00.000Z",
      "description": "Test description",
      "status": "open",
      "restrictions": "[\"Input\",\"Splitter\",\"Random\"]",
      "has_mentor_access": true,
      "current_user_project_id": null,
      "created_at": "2020-06-11T10:34:55.009Z",
      "updated_at": "2020-06-25T16:55:42.317Z",
      "grading_scale": "letter",
      "grades_finalized": false
    },
    "relationships": {
      "projects": {
        "data": []
      },
      "grades": {
        "data": []
      }
    }
  }
}
```

## DELETE Assignment

Group mentor can DELETE a assignment (identified by `:id`) in `/api/v1/assignments/:id/`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                              |
| --------- | ---------------------------------------- |
| `id`      | The `id` of the assignment to be deleted |

<aside class="warning">User with mentor or admin access can only delete the assignment</aside>

### Possible exceptions

| Error Code | Description                                                       |
| ---------- | ----------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.    |
| 403        | When non-mentor user tries to delete the assignment               |
| 404        | When the requested assignment identified by `id` does not exists. |

```http
DELETE /api/v1/assignment/:id HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 204 NO CONTENT
Content-Type: application/json
```

## REOPEN Assignment

Mentor can REOPEN a closed assignment to extend the deadline by 1 day in `/api/v1/assignments/:id/reopen`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                               |
| --------- | ----------------------------------------- |
| `id`      | The `id` of the assignment to be reopened |

<aside class="notice">Reopened assignment's deadline is increased by one day</aside>

### Possible exceptions

| Error Code | Description                                                         |
| ---------- | ------------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.      |
| 403        | When authenticated user is neither mentor nor user of the Group     |
| 404        | When the requested assignment identified by `id` does not exists.   |
| 409        | When the requested assignment identified by `id` is already opened. |

```http
PATCH /api/v1/assignments/:id/reopen HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 202 ACCEPTED
```

> JSON response example:

```json
{
  "message": "Assignment has been reopened!"
}
```

## CLOSE Assignment

Mentor can CLOSE a assignment immediately in `/api/v1/assignments/:id/close`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                               |
| --------- | ----------------------------------------- |
| `id`      | The `id` of the assignment to be closed   |

<aside class="notice">User with mentor or admin access can only close the assignment</aside>

### Possible exceptions

| Error Code | Description                                                         |
| ---------- | ------------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.      |
| 403        | When non-mentor user tries to close the assignment                  |
| 404        | When the requested assignment identified by `id` does not exists.   |
| 409        | When the requested assignment identified by `id` is already closed. |

```http
PATCH /api/v1/assignments/:id/close HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 202 ACCEPTED
```

> JSON response example:

```json
{
  "message": "Assignment has been closed!"
}
```

## START Assignment

Group Members can start working on the assignment in`/api/v1/assignments/:id/start`. This creates a new private project for he user to work upon. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                                       |
| --------- | ------------------------------------------------- |
| `id`      | The `id` of the assignment to be start working on |

<aside class="notice">Created Private Project's name is #{username}/#{assignment_name}</aside>

### Possible exceptions

| Error Code | Description                                                              |
| ---------- | ------------------------------------------------------------------------ |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.           |
| 403        | When authenticated user isn't a user of the Group, assignment is part of |
| 404        | When the requested assignment identified by `id` does not exists.        |

```http
PATCH /api/v1/assignments/:id/start HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 201 CREATED
```

> JSON response example:

```json
{
  "message": "Voila! Project set up under name #{@project.name}"
}
```
