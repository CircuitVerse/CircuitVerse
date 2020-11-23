# Projects

<aside class="notice">Thread parameters for particular project include "thread_id", "is_thread_subscribed", "is_thread_closed"</aside>

## GET All Projects

You can GET all projects in `/api/v1/projects`. Authentication `token` is passed through `Authorization` header but is **NOT** mandatory.

This endpoint fetches all the `public projects` if the user is _not authorized_. If _authorized_ it fetches all the projects user has access to including `private projects`.

### URL Query Parameters

| Parameter      | Description                                                  |
| -------------- | ------------------------------------------------------------ |
| `page[number]` | The `number`<sup>th</sup> page of the response               |
| `page[size]`   | The `size` of the `per_page` response                        |
| `filter[tag]`  | The `projects` to be filtered by `tag`                       |
| `sort`         | `,` separated `String` of `sortable params`                  |
| `include`      | Adds passed params details in `included` section of response |

<aside class="notice">include query param accepts `author` only</aside>

<aside class="success">Sortable params include "view" & "created_at". Append "+" or "-" for ascending or descending sorting respectively.</aside>

### Possible exceptions

| Error Code | Description                                                      |
| ---------- | ---------------------------------------------------------------- |
| 401        | When user tries to authenticate with invalid or corrupt `token`. |

```http
GET /api/v1/projects?include=author HTTP/1.1
Accept: application/json
Authorization: Token {token} // optional
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
      "type": "project",
      "attributes": {
        "name": "Simple LED",
        "project_access_type": "Public",
        "created_at": "2020-05-10T13:04:15.649Z",
        "updated_at": "2020-05-10T13:04:15.649Z",
        "image_preview": {
          "url": "/img/default.png"
        },
        "description": " <p>Hey there, Loving CircuitVerse</p>",
        "view": 1,
        "tags": [],
        "stars_count": 0,
        "thread_id": "1",
        "is_thread_subscribed": false,
        "is_thread_closed": false
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
      "type": "project",
      "attributes": {
        "name": "Test 1",
        "project_access_type": "Public",
        "created_at": "2020-03-21T18:59:50.380Z",
        "updated_at": "2020-03-21T18:59:54.500Z",
        "image_preview": {
          "url": "/uploads/project/image_preview/11/default.png"
        },
        "description": "",
        "view": 1,
        "tags": [],
        "stars_count": 0,
        "thread_id": "1",
        "is_thread_subscribed": false,
        "is_thread_closed": false
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
      "id": "3",
      "type": "project",
      "attributes": {
        "name": "Test 3",
        "project_access_type": "Public",
        "created_at": "2020-05-10T13:07:44.960Z",
        "updated_at": "2020-05-10T13:07:44.960Z",
        "image_preview": {
          "url": "/img/default.png"
        },
        "description": " <p>Hey there, Loving Circuitverse</p>",
        "view": 1,
        "tags": [],
        "stars_count": 0,
        "thread_id": "1",
        "is_thread_subscribed": false,
        "is_thread_closed": false
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
      "id": "4",
      "type": "project",
      "attributes": {
        "name": "Test 4",
        "project_access_type": "Public",
        "created_at": "2020-03-21T18:55:54.528Z",
        "updated_at": "2020-03-28T04:51:21.479Z",
        "image_preview": {
          "url": "/uploads/project/image_preview/10/preview_2020-03-22_00_25_54_%2B0530.jpeg"
        },
        "description": "",
        "view": 2,
        "tags": [],
        "stars_count": 1,
        "thread_id": "1",
        "is_thread_subscribed": false,
        "is_thread_closed": false
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
      "id": "5",
      "type": "project",
      "attributes": {
        "name": "Test 5",
        "project_access_type": "Public",
        "created_at": "2020-05-10T13:10:18.349Z",
        "updated_at": "2020-05-10T13:10:18.349Z",
        "image_preview": {
          "url": "/uploads/project/image_preview/18/preview_2020-03-19_09_46_53_%2B0530.jpeg"
        },
        "description": " <p>Hey there, Loving Circuitverse</p>",
        "view": 1,
        "tags": [],
        "stars_count": 0,
        "thread_id": "1",
        "is_thread_subscribed": false,
        "is_thread_closed": false
      },
      "relationships": {
        "author": {
          "data": {
            "id": "1",
            "type": "author"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "1",
      "type": "author",
      "attributes": {
        "name": "Test User",
        "email": "test@test.com"
      }
    }
  ],
  "links": {
    "self": "http://localhost:3000/api/v1/projects?page[number]=1",
    "first": "http://localhost:3000/api/v1/projects?page[number]=1",
    "prev": null,
    "next": "http://localhost:3000/api/v1/projects?page[number]=2",
    "last": "http://localhost:3000/api/v1/projects?page[number]=4"
  }
}
```

## GET User's Projects

You can GET all users specific (identified by `:id`) projects in `/api/v1/users/:id/projects`. Authentication `token` is passed through `Authorization` header but is **NOT** mandatory.

This endpoint fetches user specific `public projects` if the user is _not authenticated_ or _not authorized_ as the user identified by `:id`. If _authorized_ as the user identified by `:id` it fetches all the user specific projects including `private projects`.

### URL Parameters

| Parameter | Description                   |
| --------- | ----------------------------- |
| `id`      | The `id` to identify the user |

### URL Query Parameters

| Parameter      | Description                                                  |
| -------------- | ------------------------------------------------------------ |
| `page[number]` | The `number`<sup>th</sup> page of the response               |
| `page[size]`   | The `size` of the `per_page` response                        |
| `filter[tag]`  | The `projects` to be filtered by `tag`                       |
| `sort`         | `,` separated `String` of `sortable params`                  |
| `include`      | Adds passed params details in `included` section of response |

<aside class="notice">include query param accepts `author` only</aside>

<aside class="success">Sortable params include "view" & "created_at". Append "+" or "-" for ascending or descending sorting respectively.</aside>

### Possible exceptions

| Error Code | Description                                                   |
| ---------- | ------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token` |
| 404        | When user associated with `:id` does not exists               |

```http
GET /api/v1/users/:id/projects?include=author HTTP/1.1
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
      "type": "project",
      "attributes": {
        "name": "Test User/Test",
        "project_access_type": "Private",
        "created_at": "2020-03-28T04:14:34.683Z",
        "updated_at": "2020-05-18T16:53:07.349Z",
        "image_preview": {
          "url": "/img/default.png"
        },
        "description": null,
        "view": 11,
        "tags": [],
        "stars_count": 1,
        "thread_id": "1",
        "is_thread_subscribed": false,
        "is_thread_closed": false
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
      "type": "project",
      "attributes": {
        "name": "Test 3",
        "project_access_type": "Public",
        "created_at": "2020-03-21T18:55:54.528Z",
        "updated_at": "2020-03-28T04:51:21.479Z",
        "image_preview": {
          "url": "/uploads/project/image_preview/10/preview_2020-03-22_00_25_54_%2B0530.jpeg"
        },
        "description": "",
        "view": 2,
        "tags": [],
        "stars_count": 1,
        "thread_id": "1",
        "is_thread_subscribed": false,
        "is_thread_closed": false
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
      "id": "3",
      "type": "project",
      "attributes": {
        "name": "Simple LED",
        "project_access_type": "Public",
        "created_at": "2020-05-10T13:04:15.649Z",
        "updated_at": "2020-05-10T13:04:15.649Z",
        "image_preview": {
          "url": "/img/default.png"
        },
        "description": " <p>Hey there, Loving Circuitverse</p>",
        "view": 1,
        "tags": [],
        "stars_count": 0,
        "thread_id": "1",
        "is_thread_subscribed": false,
        "is_thread_closed": false
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
      "id": "4",
      "type": "project",
      "attributes": {
        "name": "Test 5",
        "project_access_type": "Public",
        "created_at": "2020-03-21T18:59:50.380Z",
        "updated_at": "2020-03-21T18:59:54.500Z",
        "image_preview": {
          "url": "/uploads/project/image_preview/11/default.png"
        },
        "description": "",
        "view": 1,
        "tags": [],
        "stars_count": 0,
        "thread_id": "1",
        "is_thread_subscribed": false,
        "is_thread_closed": false
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
      "id": "5",
      "type": "project",
      "attributes": {
        "name": "Simple LED",
        "project_access_type": "Public",
        "created_at": "2020-05-10T13:07:44.960Z",
        "updated_at": "2020-05-10T13:07:44.960Z",
        "image_preview": {
          "url": "/img/default.png"
        },
        "description": " <p>Hey there, Loving Circuitverse</p>",
        "view": 1,
        "tags": [],
        "stars_count": 0,
        "thread_id": "1",
        "is_thread_subscribed": false,
        "is_thread_closed": false
      },
      "relationships": {
        "author": {
          "data": {
            "id": "1",
            "type": "author"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "1",
      "type": "author",
      "attributes": {
        "name": "Test User",
        "email": "test@test.com"
      }
    }
  ],
  "links": {
    "self": "http://localhost:3000/api/v1/users/1/projects?page[number]=1",
    "first": "http://localhost:3000/api/v1/users/1/projects?page[number]=1",
    "prev": null,
    "next": "http://localhost:3000/api/v1/users/1/projects?page[number]=2",
    "last": "http://localhost:3000/api/v1/users/1/projects?page[number]=3"
  }
}
```

## GET User's Favourites

You can GET all users specific (identified by `:id`) favourites in `/api/v1/users/:id/favourites`. Authentication `token` is passed through `Authorization` header but is **NOT** mandatory.

This endpoint fetches user specific `public favourites` if the user is _not authenticated_ or _not authorized_ as the user identified by `:id`. If _authorized_ as the user identified by `:id` it fetches all the user specific favourites including `private projects`.

### URL Parameters

| Parameter | Description                   |
| --------- | ----------------------------- |
| `id`      | The `id` to identify the user |

### URL Query Parameters

| Parameter      | Description                                                  |
| -------------- | ------------------------------------------------------------ |
| `page[number]` | The `number`<sup>th</sup> page of the response               |
| `page[size]`   | The `size` of the `per_page` response                        |
| `filter[tag]`  | The `projects` to be filtered by `tag`                       |
| `sort`         | `,` separated `String` of `sortable params`                  |
| `include`      | Adds passed params details in `included` section of response |

<aside class="notice">include query param accepts `author` only</aside>

<aside class="success">Sortable params include "view" & "created_at". Append "+" or "-" for ascending or descending sorting respectively.</aside>

### Possible exceptions

| Error Code | Description                                                   |
| ---------- | ------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token` |
| 404        | When user associated with `:id` does not exists               |

```http
GET /api/v1/users/:id/favourites?include=author HTTP/1.1
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
      "type": "project",
      "attributes": {
        "name": "Test User/Test",
        "project_access_type": "Private",
        "created_at": "2020-03-28T04:14:34.683Z",
        "updated_at": "2020-05-18T16:53:07.349Z",
        "image_preview": {
          "url": "/img/default.png"
        },
        "description": null,
        "view": 11,
        "tags": [],
        "stars_count": 1,
        "thread_id": "1",
        "is_thread_subscribed": false,
        "is_thread_closed": false
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
      "type": "project",
      "attributes": {
        "name": "Test 3",
        "project_access_type": "Public",
        "created_at": "2020-03-21T18:55:54.528Z",
        "updated_at": "2020-03-28T04:51:21.479Z",
        "image_preview": {
          "url": "/uploads/project/image_preview/10/preview_2020-03-22_00_25_54_%2B0530.jpeg"
        },
        "description": "",
        "view": 2,
        "tags": [],
        "stars_count": 1,
        "thread_id": "1",
        "is_thread_subscribed": false,
        "is_thread_closed": false
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
      "id": "3",
      "type": "project",
      "attributes": {
        "name": "Simple LED",
        "project_access_type": "Public",
        "created_at": "2020-05-10T13:04:15.649Z",
        "updated_at": "2020-05-10T13:04:15.649Z",
        "image_preview": {
          "url": "/img/default.png"
        },
        "description": " <p>Hey there, Loving Circuitverse</p>",
        "view": 1,
        "tags": [],
        "stars_count": 0,
        "thread_id": "1",
        "is_thread_subscribed": false,
        "is_thread_closed": false
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
      "id": "4",
      "type": "project",
      "attributes": {
        "name": "Test 5",
        "project_access_type": "Public",
        "created_at": "2020-03-21T18:59:50.380Z",
        "updated_at": "2020-03-21T18:59:54.500Z",
        "image_preview": {
          "url": "/uploads/project/image_preview/11/default.png"
        },
        "description": "",
        "view": 1,
        "tags": [],
        "stars_count": 0,
        "thread_id": "1",
        "is_thread_subscribed": false,
        "is_thread_closed": false
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
      "id": "5",
      "type": "project",
      "attributes": {
        "name": "Simple LED",
        "project_access_type": "Public",
        "created_at": "2020-05-10T13:07:44.960Z",
        "updated_at": "2020-05-10T13:07:44.960Z",
        "image_preview": {
          "url": "/img/default.png"
        },
        "description": " <p>Hey there, Loving Circuitverse</p>",
        "view": 1,
        "tags": [],
        "stars_count": 0,
        "thread_id": "1",
        "is_thread_subscribed": false,
        "is_thread_closed": false
      },
      "relationships": {
        "author": {
          "data": {
            "id": "1",
            "type": "author"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "1",
      "type": "author",
      "attributes": {
        "name": "Test User",
        "email": "test@test.com"
      }
    }
  ],
  "links": {
    "self": "http://localhost:3000/api/v1/users/1/favourites?page[number]=1",
    "first": "http://localhost:3000/api/v1/users/1/favourites?page[number]=1",
    "prev": null,
    "next": "http://localhost:3000/api/v1/users/1/favourites?page[number]=2",
    "last": "http://localhost:3000/api/v1/users/1/favourites?page[number]=3"
  }
}
```

## GET Project Details

You can GET project details (identified by `:id`) in `/api/v1/projects/:id/`. Authentication `token` is passed through `Authorization` header but is **NOT** mandatory.

### URL Parameters

| Parameter | Description                                                  |
| --------- | ------------------------------------------------------------ |
| `id`      | The `id` of the project to be detailed                       |
| `include` | Adds passed params details in `included` section of response |

<aside class="notice">include query param accepts `author` only</aside>

### Possible exceptions

| Error Code | Description                                                              |
| ---------- | ------------------------------------------------------------------------ |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.           |
| 403        | When Project is `private` or `authenticated user` doesn't have access to |
| 404        | When the requested project identified by `id` does not exists.           |

```http
GET /api/v1/projects/:id?include=author HTTP/1.1
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
    "type": "project",
    "attributes": {
      "name": "Simple LED",
      "project_access_type": "Public",
      "created_at": "2020-03-19T04:16:53.543Z",
      "updated_at": "2020-05-10T13:18:13.814Z",
      "image_preview": {
        "url": "/uploads/project/image_preview/9/preview_2020-03-19_09_46_53_%2B0530.jpeg"
      },
      "description": " <p>Hey there, Loving Circuitverse</p>",
      "view": 2,
      "tags": [
        {
          "id": 1,
          "name": "CV",
          "created_at": "2020-03-10T13:02:10.381Z",
          "updated_at": "2020-03-10T13:02:10.381Z"
        }
      ],
      "stars_count": 1,
      "thread_id": "1",
      "is_thread_subscribed": false,
      "is_thread_closed": false
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
  "included": [
    {
      "id": "1",
      "type": "author",
      "attributes": {
        "name": "Test User",
        "email": "test@test.com"
      }
    }
  ]
}
```

## UPDATE Project

You can UPDATE project details (identified by `:id`) in `/api/v1/projects/:id/`. Authentication `token` is passed through `Authorization` header and is **required**.

### List of acceptable params for put/patch requests include:

| Name                  | Type     | Description                        |
| --------------------- | -------- | ---------------------------------- |
| `name`                | `String` | Updated name of the project        |
| `project_access_type` | `String` | `Public` or `Private`              |
| `description`         | `String` | Updated description of the project |
| `tag_list`            | `String` | Comma separated String of tags     |

### URL Parameters

| Parameter | Description                                                  |
| --------- | ------------------------------------------------------------ |
| `id`      | The `id` of the project to be detailed                       |
| `include` | Adds passed params details in `included` section of response |

<aside class="notice">include query param accepts `author` only</aside>

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 400        | When invalid parameters are used.                              |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |
| 403        | When Project `author` differs from `authenticated user`        |
| 404        | When the requested project identified by `id` does not exists. |

```http
PATCH /api/v1/projects/:id?include=author HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```json
{
  "project": {
    "name": "Simple LED Updated"
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
    "type": "project",
    "attributes": {
      "name": "Simple LED Updated",
      "project_access_type": "Public",
      "created_at": "2020-03-19T04:16:53.543Z",
      "updated_at": "2020-05-10T13:18:13.814Z",
      "image_preview": {
        "url": "/uploads/project/image_preview/9/preview_2020-03-19_09_46_53_%2B0530.jpeg"
      },
      "description": " <p>Hey there, Loving Circuitverse</p>",
      "view": 2,
      "tags": [
        {
          "id": 1,
          "name": "CV",
          "created_at": "2020-03-10T13:02:10.381Z",
          "updated_at": "2020-03-10T13:02:10.381Z"
        }
      ],
      "stars_count": 1,
      "thread_id": "1",
      "is_thread_subscribed": false,
      "is_thread_closed": false
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
  "included": [
    {
      "id": "1",
      "type": "author",
      "attributes": {
        "name": "Test User",
        "email": "test@test.com"
      }
    }
  ]
}
```

## DELETE Project

You can DELETE project (identified by `:id`) in `/api/v1/projects/:id/`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                           |
| --------- | ------------------------------------- |
| `id`      | The `id` of the project to be deleted |

<aside class="warning">User with author access can only delete the project</aside>

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |
| 403        | When Project `author` differs from `authenticated user`        |
| 404        | When the requested project identified by `id` does not exists. |

```http
DELETE /api/v1/projects/:id HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 204 NO CONTENT
Content-Type: application/json
```

## GET Featured Projects

You can GET all featured projects in `/api/v1/projects/featured`.

### URL Query Parameters

| Parameter      | Description                                                  |
| -------------- | ------------------------------------------------------------ |
| `page[number]` | The `number`<sup>th</sup> page of the response               |
| `page[size]`   | The `size` of the `per_page` response                        |
| `filter[tag]`  | The `projects` to be filtered by `tag`                       |
| `sort`         | `,` separated `String` of `sortable params`                  |
| `include`      | Adds passed params details in `included` section of response |

<aside class="notice">include query param accepts `author` only</aside>

<aside class="success">Sortable params include "view" & "created_at". Append "+" or "-" for ascending or descending sorting respectively.</aside>

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |

```http
GET /api/v1/projects/featured?include=author HTTP/1.1
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
      "type": "project",
      "attributes": {
        "name": "Simple LED",
        "project_access_type": "Public",
        "created_at": "2020-03-19T04:16:53.543Z",
        "updated_at": "2020-05-10T13:18:13.814Z",
        "image_preview": {
          "url": "/uploads/project/image_preview/9/preview_2020-03-19_09_46_53_%2B0530.jpeg"
        },
        "description": " <p>Hey there, Loving Circuitverse</p>",
        "view": 2,
        "tags": [
          {
            "id": 1,
            "name": "CV",
            "created_at": "2020-03-10T13:02:10.381Z",
            "updated_at": "2020-03-10T13:02:10.381Z"
          }
        ],
        "stars_count": 1,
        "thread_id": "1",
        "is_thread_subscribed": false,
        "is_thread_closed": false
      },
      "relationships": {
        "author": {
          "data": {
            "id": "1",
            "type": "author"
          }
        }
      }
    }
  ],
  "included": [
    {
      "id": "1",
      "type": "author",
      "attributes": {
        "name": "Test User",
        "email": "test@test.com"
      }
    }
  ],
  "links": {
    "self": "http://localhost:3000/api/v1/projects/featured?page[number]=1",
    "first": "http://localhost:3000/api/v1/projects/featured?page[number]=1",
    "prev": null,
    "next": null,
    "last": "http://localhost:3000/api/v1/projects/featured?page[number]=1"
  }
}
```

## STAR/UNSTAR a Project

You can star or unstar a project in `/api/v1/projects/:id/toggle-star`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                           |
| --------- | ------------------------------------- |
| `id`      | The `id` of the project to be starred |

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |
| 404        | When the requested project identified by `id` does not exists. |

```http
GET /api/v1/projects/:id/toggle-star HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 200 OK
Content-Type: application/json
```

```json
{
  "message": "Starred/Unstarred successfully!"
}
```

## FORK a Project

You can FORK a project (identified by `:id`) in `/api/v1/projects/:id/fork`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                            |
| --------- | -------------------------------------- |
| `id`      | The `id` of the project to be detailed |

<aside class="notice">author details in the included section</aside>

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |
| 409        | When user tries ot fork his/her own project                    |
| 404        | When the requested project identified by `id` does not exists. |

```http
GET /api/v1/projects/:id/fork HTTP/1.1
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
    "id": "2",
    "type": "project",
    "attributes": {
      "name": "Test User/Simple LED",
      "project_access_type": "Public",
      "created_at": "2020-03-19T04:16:53.543Z",
      "updated_at": "2020-05-10T13:18:13.814Z",
      "image_preview": {
        "url": "/uploads/project/image_preview/9/preview_2020-03-19_09_46_53_%2B0530.jpeg"
      },
      "description": " <p>Hey there, Loving Circuitverse</p>",
      "view": 2,
      "tags": [
        {
          "id": 1,
          "name": "CV",
          "created_at": "2020-03-10T13:02:10.381Z",
          "updated_at": "2020-03-10T13:02:10.381Z"
        }
      ],
      "stars_count": 1,
      "thread_id": "1",
      "is_thread_subscribed": false,
      "is_thread_closed": false
    },
    "relationships": {
      "author": {
        "data": {
          "id": "1",
          "type": "author"
        }
      }
    }
  }
}
```
