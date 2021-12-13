# Collaborators

## GET All project collaborators

You can GET all collaborators for a particular project in `/api/v1/projects/:project_id/collaborators`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Query Parameters

| Parameter      | Description                                    |
| -------------- | ---------------------------------------------- |
| `page[number]` | The `number`<sup>th</sup> page of the response |
| `page[size]`   | The `size` of the `per_page` response          |

### Possible exceptions

| Error Code | Description                                                      |
| ---------- | ---------------------------------------------------------------- |
| 401        | When user tries to authenticate with invalid or corrupt `token`. |

```http
GET /api/v1/projects/:project_id/collaborators HTTP/1.1
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
      "type": "user",
      "attributes": {
        "name": "Collaborator's Name"
      }
    }
  ],
  "links": {
    "self": "http://localhost:3000/api/v1/projects/1/collaborators?page[number]=1",
    "first": "http://localhost:3000/api/v1/projects/1/collaborators?page[number]=1",
    "prev": null,
    "next": null,
    "last": "http://localhost:3000/api/v1/projects/1/collaborators?page[number]=1"
  }
}
```

## CREATE/ADD Collaborator

Project author can add collaborators to his/her project in `/api/v1/projects/:project_id/collaborators`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter    | Description                                            |
| ------------ | ------------------------------------------------------ |
| `project_id` | The `id` of the project, collaborators are to be added |

<aside class="notice">emails in POST request is comma separated string of emails</aside>

<aside class="warning">You cannot add yourself as a collaborator</aside>

### Possible exceptions

| Error Code | Description                                                            |
| ---------- | ---------------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.         |
| 403        | When non-author user tries to add collaborators to the project         |
| 404        | When the requested project identified by `project_id` does not exists. |

```http
POST /api/v1/projects/:project_id/collaborators HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```json
{
  "emails": "newuser@test.com, alreadyCollaborating@test.com, NA"
}
```

```http
HTTP/1.1 200 OK
```

> JSON response example:

```json
{
  "added": ["newuser@test.com"],
  "existing": ["alreadyCollaborating@test.com"],
  "invalid": ["NA"]
}
```

## DELETE Collaborator

Project author can DELETE a collaborator (identified by `:id`) in `/api/v1/projects/:project_id/collaborators/:id`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter    | Description                                                 |
| ------------ | ----------------------------------------------------------- |
| `project_id` | The `id` of the project, collaborators are to be deleted of |
| `id`         | The `id` of the collaborating member                        |

<aside class="warning">User with author access can only delete a collaborator</aside>

### Possible exceptions

| Error Code | Description                                                            |
| ---------- | ---------------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.         |
| 403        | When non-author user tries to delete the collaborator                  |
| 404        | When the requested project identified by `project_id` does not exists. |
| 404        | When the requested collaborator identified by `id` does not exists.    |

```http
DELETE /api/v1/projects/:project_id/collaborators/:id HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 204 NO CONTENT
Content-Type: application/json
```
