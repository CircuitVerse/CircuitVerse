# Grades

## CREATE/ADD Grade

You can grade an assignment in `/api/v1/assignments/:assignment_id/projects/:project_id/grades`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter       | Description                                   |
| --------------- | --------------------------------------------- |
| `assignment_id` | The `id` of the assignment project belongs to |
| `project_id`    | The `id` of the the project you wish to grade |

<aside class="warning">The assignment can only be graded by a group mentor</aside>

### Possible exceptions

| Error Code | Description                                                        |
| ---------- | ------------------------------------------------------------------ |
| 401        | When user is not authenticated i.e invalid or corrupt `token`.     |
| 403        | When non-mentor user tries to grade the assignment                 |
| 404        | When the assignment identified by `assignment_id` does not exists. |
| 422        | When created grade has validation errors                           |

```http
POST /api/v1/assignments/:assignment_id/projects/:project_id/grade HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```json
{
  "grade": {
    "grade": "A",
    "remarks": "This is the remark.."
  }
}
```

```http
HTTP/1.1 201 CREATED
```

> JSON response example:

```json
{
  "data": {
    "id": "1",
    "type": "grade",
    "attributes": {
      "grade": "A",
      "remarks": "This is the remark..",
      "created_at": "2020-06-11T04:02:44.466Z",
      "updated_at": "2020-06-11T04:02:44.466Z"
    },
    "relationships": {
      "project": {
        "data": {
          "id": "1",
          "type": "project"
        }
      }
    }
  }
}
```

## UPDATE Grade

You can update grade identified by `:id` in `/api/v1/grades/:id`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                         |
| --------- | ----------------------------------- |
| `id`      | The `id` of the grade to be updated |

<aside class="warning">The grade can only be updated by a group mentor</aside>

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |
| 403        | When non-mentor user tries to update grade for the assignment  |
| 404        | When the grade identified by `id` does not exists.             |
| 422        | When updated grade has validation errors                       |

```http
POST /api/v1/assignments/:assignment_id/projects/:project_id/grade HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```json
{
  "grade": {
    "grade": "B",
    "remarks": "This is the updated remark.."
  }
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
    "type": "grade",
    "attributes": {
      "grade": "B",
      "remarks": "This is the updated remark..",
      "created_at": "2020-06-11T04:02:44.466Z",
      "updated_at": "2020-06-11T04:02:44.466Z"
    },
    "relationships": {
      "project": {
        "data": {
          "id": "1",
          "type": "project"
        }
      }
    }
  }
}
```

## DELETE Grade

A Group mentor can DELETE a grade (identified by `:id`) in `/api/v1/grades/:id/`. Authentication `token` is passed through `Authorization` header and is **required**.

### URL Parameters

| Parameter | Description                         |
| --------- | ----------------------------------- |
| `id`      | The `id` of the grade to be deleted |

<aside class="warning">User with mentor or admin access can only delete the grades</aside>

### Possible exceptions

| Error Code | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| 401        | When user is not authenticated i.e invalid or corrupt `token`. |
| 403        | When non-mentor user tries to delete the grade                 |
| 404        | When the requested grade identified by `id` does not exists.   |

```http
DELETE /api/v1/grades/:id HTTP/1.1
Accept: application/json
Authorization: Token {token}
Host: localhost
```

```http
HTTP/1.1 204 NO CONTENT
Content-Type: application/json
```
