# Authentication

In order to make requests that require the user to be authenticated, you must retrieve the token to be able to act on the behalf of the user.

## SIGNUP User

This endpoint gives back the authentication token that encodes user's `id`, `name` and `email`.

### Possible exceptions

| Error Code | Description                    |
| ---------- | ------------------------------ |
| 409        | When user already exists.      |
| 422        | Invalid or missing parameters. |

```http
POST /api/v1/auth/signup HTTP/1.1
Accept: application/json
Host: localhost
```

```json
{
  "email": "test@test.com",
  "password": "12345678",
  "name": "Test Name"
}
```

```http
HTTP/1.1 201 CREATED
Content-Type: application/json
```

> JSON response example:

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjp7InVzZXJfaWQiOjIsInVzZXJuYW1lIjoiTml0aXNoIEFnZ2Fyd2FsIiwiZW1haWwiOiJyb3lhbG5pdGlzaDIxQGdtYWlsLmNvbSJ9LCJleHAiOjE1ODkyMDI5ODF9.tHRLJeQGuLiJ1Ncc2tQSaNiQnbrnERKuOPERfZeNnF8"
}
```

## LOGIN User

This endpoint gives back the authentication token that encodes user's `id`, `name` and `email`.

### Possible exceptions

| Error Code | Description                       |
| ---------- | --------------------------------- |
| 401        | Invalid password.                 |
| 404        | Non existent user tries to login. |

```http
POST /api/v1/auth/login HTTP/1.1
Accept: application/json
Host: localhost
```

```json
{
  "email": "test@test.com",
  "password": "12345678"
}
```

```http
HTTP/1.1 202 ACCEPTED
Content-Type: application/json
```

> JSON response example:

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjp7InVzZXJfaWQiOjIsInVzZXJuYW1lIjoiTml0aXNoIEFnZ2Fyd2FsIiwiZW1haWwiOiJyb3lhbG5pdGlzaDIxQGdtYWlsLmNvbSJ9LCJleHAiOjE1ODkyMDI5ODF9.tHRLJeQGuLiJ1Ncc2tQSaNiQnbrnERKuOPERfZeNnF8"
}
```

## OAUTH SignUp

This endpoint gives creates a user using the user details fetched from appropriate `provider` authenticated by `access_token`. The response shall contain the `token` encoding user's `id`, `name` and `email`.

<aside class="notice">The accepted providers are google, facebook, github.</aside>

### Possible exceptions

| Error Code | Description                                       |
| ---------- | ------------------------------------------------- |
| 401        | If `access_token` is corrupt or invalid.          |
| 404        | When requested `provider` is not supported.       |
| 409        | When user already exists.                         |
| 422        | Invalid or missing details from `oauth` provider. |

```http
POST /api/v1/oauth/signup HTTP/1.1
Accept: application/json
Host: localhost
```

```json
{
  "access_token": "eyJ.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuYXV0aDAuY29tLyIsImF1ZCI6Imh0dHBzOi8vYXBpLmV4YW1wbGUuY29tL2NhbGFuZGFyL3YxLyIsInN1YiI6InVzcl8xMjMiLCJpYXQiOjE0NTg3ODU3OTYsImV4cCI6MTQ1ODg3MjE5Nn0.CA7eaHjIHz5NxeIJoFK9krqaeZrPLwmMmgI_XiQiIkQ",
  "provider": "google"
}
```

```http
HTTP/1.1 201 CREATED
Content-Type: application/json
```

> JSON response example:

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjp7InVzZXJfaWQiOjIsInVzZXJuYW1lIjoiTml0aXNoIEFnZ2Fyd2FsIiwiZW1haWwiOiJyb3lhbG5pdGlzaDIxQGdtYWlsLmNvbSJ9LCJleHAiOjE1ODkyMDI5ODF9.tHRLJeQGuLiJ1Ncc2tQSaNiQnbrnERKuOPERfZeNnF8"
}
```

## OAUTH Login

This endpoint finds the user with user params fetched from appropriate `provider` authenticated by `access_token`. The response shall contain the `token` encoding user's `id`, `name` and `email`.

<aside class="notice">The accepted providers are google, facebook, github.</aside>

### Possible exceptions

| Error Code | Description                                                     |
| ---------- | --------------------------------------------------------------- |
| 401        | If `access_token` is corrupt or invalid.                        |
| 404        | When requested `provider` is not supported or `user` not found. |
| 422        | Invalid or missing details from `oauth` provider.               |

```http
POST /api/v1/oauth/login HTTP/1.1
Accept: application/json
Host: localhost
```

```json
{
  "access_token": "eyJ.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuYXV0aDAuY29tLyIsImF1ZCI6Imh0dHBzOi8vYXBpLmV4YW1wbGUuY29tL2NhbGFuZGFyL3YxLyIsInN1YiI6InVzcl8xMjMiLCJpYXQiOjE0NTg3ODU3OTYsImV4cCI6MTQ1ODg3MjE5Nn0.CA7eaHjIHz5NxeIJoFK9krqaeZrPLwmMmgI_XiQiIkQ",
  "provider": "google"
}
```

```http
HTTP/1.1 202 ACCEPTED
Content-Type: application/json
```

> JSON response example:

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjp7InVzZXJfaWQiOjIsInVzZXJuYW1lIjoiTml0aXNoIEFnZ2Fyd2FsIiwiZW1haWwiOiJyb3lhbG5pdGlzaDIxQGdtYWlsLmNvbSJ9LCJleHAiOjE1ODkyMDI5ODF9.tHRLJeQGuLiJ1Ncc2tQSaNiQnbrnERKuOPERfZeNnF8"
}
```

## OAUTH SignUp

This endpoint gives creates a user using the user details fetched from appropriate `provider` authenticated by `access_token`. The response shall contain the `token` encoding user's `id`, `name` and `email`.

<aside class="notice">The accepted providers are google, facebook, github.</aside>

### Possible exceptions

| Error Code | Description                                       |
| ---------- | ------------------------------------------------- |
| 401        | If `access_token` is corrupt or invalid.          |
| 404        | When requested `provider` is not supported.       |
| 409        | When user already exists.                         |
| 422        | Invalid or missing details from `oauth` provider. |

```http
POST /api/v1/oauth/signup HTTP/1.1
Accept: application/json
Host: localhost
```

```json
{
  "access_token": "eyJ.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuYXV0aDAuY29tLyIsImF1ZCI6Imh0dHBzOi8vYXBpLmV4YW1wbGUuY29tL2NhbGFuZGFyL3YxLyIsInN1YiI6InVzcl8xMjMiLCJpYXQiOjE0NTg3ODU3OTYsImV4cCI6MTQ1ODg3MjE5Nn0.CA7eaHjIHz5NxeIJoFK9krqaeZrPLwmMmgI_XiQiIkQ",
  "provider": "google"
}
```

```http
HTTP/1.1 201 CREATED
Content-Type: application/json
```

> JSON response example:

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjp7InVzZXJfaWQiOjIsInVzZXJuYW1lIjoiTml0aXNoIEFnZ2Fyd2FsIiwiZW1haWwiOiJyb3lhbG5pdGlzaDIxQGdtYWlsLmNvbSJ9LCJleHAiOjE1ODkyMDI5ODF9.tHRLJeQGuLiJ1Ncc2tQSaNiQnbrnERKuOPERfZeNnF8"
}
```

## OAUTH Login

This endpoint finds the user with user params fetched from appropriate `provider` authenticated by `access_token`. The response shall contain the `token` encoding user's `id`, `name` and `email`.

<aside class="notice">The accepted providers are google, facebook, github.</aside>

### Possible exceptions

| Error Code | Description                                                     |
| ---------- | --------------------------------------------------------------- |
| 401        | If `access_token` is corrupt or invalid.                        |
| 404        | When requested `provider` is not supported or `user` not found. |
| 422        | Invalid or missing details from `oauth` provider.               |

```http
POST /api/v1/oauth/login HTTP/1.1
Accept: application/json
Host: localhost
```

```json
{
  "access_token": "eyJ.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuYXV0aDAuY29tLyIsImF1ZCI6Imh0dHBzOi8vYXBpLmV4YW1wbGUuY29tL2NhbGFuZGFyL3YxLyIsInN1YiI6InVzcl8xMjMiLCJpYXQiOjE0NTg3ODU3OTYsImV4cCI6MTQ1ODg3MjE5Nn0.CA7eaHjIHz5NxeIJoFK9krqaeZrPLwmMmgI_XiQiIkQ",
  "provider": "google"
}
```

```http
HTTP/1.1 202 ACCEPTED
Content-Type: application/json
```

> JSON response example:

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjp7InVzZXJfaWQiOjIsInVzZXJuYW1lIjoiTml0aXNoIEFnZ2Fyd2FsIiwiZW1haWwiOiJyb3lhbG5pdGlzaDIxQGdtYWlsLmNvbSJ9LCJleHAiOjE1ODkyMDI5ODF9.tHRLJeQGuLiJ1Ncc2tQSaNiQnbrnERKuOPERfZeNnF8"
}
```

## SEND Reset Password Instructions

This endpoint sends an email to the user with specified `email` in POST params with instructions to reset his/her password.

### Possible exceptions

| Error Code | Description                                        |
| ---------- | -------------------------------------------------- |
| 404        | User associated with given `email` does not exists |

```http
POST /api/v1/password/forgot HTTP/1.1
Accept: application/json
Host: localhost
```

```json
{
  "email": "test@test.com"
}
```

```http
HTTP/1.1 200 OK
Content-Type: application/json
```

> JSON response example:

```json
{
  "message": "password reset instructions sent to test@test.com"
}
```

## GET Public Key

This endpoint GETs you the `public_key.pem` required to decode the token to fetch authenticated user's `id`, `name` & `email`.

```http
POST /api/v1/public_key.pem HTTP/1.1
Host: localhost
```

```http
HTTP/1.1 200 OK
Content-Type: application/json
```

> TEXT response example:

```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA3D8j5djbLuNcEwWEEU4v
Y38gIpaZrDvnec2DyRwzt+pvMuFPcrfnjAkVBTeYwiGdhH3eNSm3juJZHH506x3I
mKuQp7vo6Ni+vZVsYyA5kVuj+Qv4bR3DjFh/Hd4O2dcXfcsFgjnM7sUv6Oxa3tDi
9869O4BQNnddiOjMj2S+9NJePMWjItBMA7LwYq1n3NVQbW4m3tSb5h/V/PpVspgV
rF0ZO4xczXjGzhsapkFdibfIuac6BH74xyUwlizmu8GStap2VnFlSYiIoAEtfBp9
HKl1z24Yoa4Wu+Li9wVrKYueMjbxVicvNeOxvMEVD5/xI0o1z0rT7srzkr1TCdCd
6QIDAQAB
-----END PUBLIC KEY-----
```
