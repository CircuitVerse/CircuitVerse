# LTI 1.3 OIDC Launch Flow — CircuitVerse POC

> GSoC 2026 POC — Option B: Integrated into CircuitVerse alongside existing LTI 1.1

## What This Implements

This adds **LTI 1.3 OIDC third-party login** to CircuitVerse as a Proof of Concept. When launched from a Learning Management System (LMS) that supports LTI 1.3, CircuitVerse:

1. Receives an OIDC login initiation request
2. Redirects the user's browser to the platform's authorization endpoint
3. Receives a signed JWT (id_token) via form POST
4. Verifies the JWT signature against the platform's JWKS
5. Renders the decoded claims for verification

The existing **LTI 1.1 implementation is completely untouched** — both versions coexist.

---

## Prerequisites

- Rails development environment (Docker recommended)
- OpenSSL (for key generation)
- [ngrok](https://ngrok.com/) (for external testing with saLTIre)

---

## Setup

### 1. Run Migrations

```bash
# Docker
docker compose exec web bundle exec rails db:migrate

# Native
bundle exec rails db:migrate
```

This creates:
- `lti_platforms` table (stores LTI 1.3 platform registrations)
- `lti_deployment_id` column on `assignments` (for future deployment tracking)

### 2. Generate RSA Key Pair

```bash
openssl genrsa -out tmp/lti_private_key.pem 2048
```

### 3. Add to Rails Credentials

```bash
EDITOR="code --wait" rails credentials:edit
```

Add:
```yaml
lti_tool_private_key: |
  -----BEGIN RSA PRIVATE KEY-----
  [paste contents of tmp/lti_private_key.pem]
  -----END RSA PRIVATE KEY-----

lti_tool_kid: "circuitverse-lti-key-1"
```

### 4. Seed saLTIre Platform

```ruby
# In rails console
LtiPlatform.create!(
  issuer:        "https://saltire.lti.app",
  client_id:     "saltire.lti.app",
  auth_url:      "https://saltire.lti.app/platform/auth",
  token_url:     "https://saltire.lti.app/platform/token",
  jwks_url:      "https://saltire.lti.app/platform/jwks",
  deployment_id: "1"
)
```

### 5. Start ngrok and Configure saLTIre

```bash
ngrok http 3000
```

At https://saltire.lti.app/platform configure:

| Field | Value |
|---|---|
| OIDC Login Initiation URL | `https://YOUR_NGROK/lti/v1p3/oidc/login` |
| Launch / Redirect URL | `https://YOUR_NGROK/lti/v1p3/oidc/callback` |
| JWKS URL | `https://YOUR_NGROK/lti/v1p3/jwks` |
| Client ID | `saltire.lti.app` |

Click **Launch** — you should see the decoded JWT claims page.

---

## Endpoint Reference

| Route | Method | Purpose |
|---|---|---|
| `/lti/launch` | GET/POST | **Existing** LTI 1.1 launch (untouched) |
| `/lti/v1p3/jwks` | GET | Serves tool RSA public key in JWK format |
| `/lti/v1p3/oidc/login` | POST | OIDC login initiation — validates issuer, redirects to platform auth |
| `/lti/v1p3/oidc/callback` | POST | Receives JWT id_token, verifies signature, renders decoded claims |

---

## Gems Used

| Gem | Version | Purpose |
|---|---|---|
| `jwt` | 2.10.2 | JWT decode, verify, encode (already in Gemfile) |
| `Net::HTTP` | stdlib | Fetch platform JWKS, AGS token requests |
| `OpenSSL` | stdlib | RSA key operations |
| `SecureRandom` | stdlib | State/nonce generation |

**No new gems were added.** Everything uses existing dependencies.

---

## Files Added

| File | Purpose |
|---|---|
| `app/controllers/lti/v1p3/launches_controller.rb` | OIDC flow controller |
| `app/models/lti_platform.rb` | Platform registration model |
| `app/views/lti/v1p3/launches/launch_success.html.erb` | Decoded claims view |
| `db/migrate/*_add_lti_deployment_id_to_assignments.rb` | Schema migration |
| `db/migrate/*_create_lti_platforms.rb` | Platform table migration |
| `README_LTI13.md` | This file |

## Files Modified

| File | Change |
|---|---|
| `config/routes.rb` | Added 3 routes inside existing `scope 'lti'` block |

## Files NOT Modified

- `app/controllers/lti_controller.rb` — LTI 1.1 untouched
- `app/services/lti_score_submission.rb` — Grade passback untouched
- `spec/requests/lti_spec.rb` — All existing tests pass unchanged

---

## How Existing LTI 1.1 Is Unaffected

The new LTI 1.3 routes are namespaced under `/lti/v1p3/`, completely independent of the existing `/lti/launch` route. The existing controller, service, views, helper, and tests are never touched.

---

## Production Considerations

For a production deployment beyond this POC:

1. **Session Storage**: Replace cookie-based sessions with Redis for nonce/state storage (prevents replay attacks at scale)
2. **Platform Registration UI**: Add an admin interface for registering LTI platforms (currently seeded via console)
3. **JWKS Caching**: Cache platform JWKS responses with automatic refresh (avoid fetching on every launch)
4. **User Provisioning**: Auto-create CircuitVerse accounts from LTI claims or match by email
5. **Assignment Linking**: Map LTI resource links to CircuitVerse assignments via `lti_deployment_id`
6. **AGS Integration**: Use `projects.lis_result_sourced_id` to store lineitem URLs for LTI 1.3 grade passback
7. **Rate Limiting**: Rate-limit the `/lti/v1p3/jwks` endpoint

---

## Screenshots

_Add screenshots of successful saLTIre launch here_
