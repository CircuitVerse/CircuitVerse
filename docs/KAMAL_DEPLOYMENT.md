# Kamal 2 Deployment Environment for CircuitVerse

This document describes the Kamal 2-based deployment setup for CircuitVerse.

---

## 1. Architecture Overview

Kamal 2 is a container orchestration tool designed for deploying Dockerized web applications to bare-metal servers or cloud virtual machines (VPS) with zero downtime.

In CircuitVerse, Kamal 2 manages:
- **`web` role:** Runs Rails Puma web server (`./bin/rails server -b 0.0.0.0 -p 3000`) on port 3000.
- **`sidekiq` role:** Runs background job processing (`bundle exec sidekiq -e production -q default -q mailers`).
- **`kamal-proxy`:** High-performance proxy that replaces Kamal 1's Traefik. It routes HTTP/HTTPS traffic to the active app container, automatically manages Let's Encrypt SSL/TLS certificates, and orchestrates zero-downtime container swaps.
- **`database` accessory:** PostgreSQL 19 container (`postgres:19-alpine`) running with a persistent volume mounted at `/var/lib/postgresql` and safely bound to localhost (`127.0.0.1:5432:5432`).
- **`redis` accessory:** Redis 7.2 container (`redis:7.2-alpine`) running with a persistent volume mounted at `/data` and safely bound to localhost (`127.0.0.1:6379:6379`).
- **Asset Bridging (`asset_path`):** Mounts a shared assets directory so assets from both active and previous deployments remain available during rolling updates, eliminating 404 errors for users with open browser tabs.

---

## 2. File Structure

```
CircuitVerse/
├── .kamal/
│   ├── secrets.example           # Template for deployment secrets
│   ├── secrets                   # Local secrets mapping (git-ignored)
│   └── hooks/                    # Deployment hooks
│       ├── pre-deploy.sample     # Hook before deploy starts
│       └── post-deploy.sample    # Hook after deploy succeeds (e.g. notifications)
├── config/
│   ├── deploy.yml                # Base Kamal 2 configuration
│   ├── deploy.staging.yml        # Staging destination overrides (`-d staging`)
│   └── deploy.production.yml     # Production destination overrides (`-d production`)
├── .github/workflows/
│   ├── docker-publish.yml        # Builds and pushes multi-arch images to GHCR
│   └── deploy.yml                # Automated deployment workflow using Kamal 2
└── Dockerfile.production         # Multi-stage production container build
```

---

## 3. Configuration Details

### `config/deploy.yml`
Key settings:
- **Service Name:** `circuitverse`
- **Image:** `ghcr.io/circuitverse/circuitverse`
- **Roles:**
  - `web`: `cmd: ./bin/rails server -b 0.0.0.0 -p 3000` with host gateway option.
  - `sidekiq`: `cmd: bundle exec sidekiq -e production -q default -q mailers`.
- **Proxy:**
  - `ssl: true`: Provisions automatic Let's Encrypt certificates.
  - `host`: Target domain (defaults to `staging.circuitverse.org` or can be overridden via `APP_HOST`).
  - `app_port: 3000`: Points proxy to Puma internal port.
  - `forward_headers: true`: Forwards `X-Forwarded-*` headers to Rails.
  - `healthcheck.path: /up`: Checks Rails healthcheck endpoint.
- **Asset Path:** `/usr/src/app/public/assets` for zero-downtime rolling deploys.
- **Accessories:**
  - `database`: PostgreSQL 19 Alpine container with persistent storage volume and network alias `database`.
  - `redis`: Redis 7.2 Alpine container with persistent storage volume and network alias `redis`.

### Destinations
- **Staging (`-d staging`):**
  Uses domain `staging.circuitverse.org` and bucket `circuitverse-images-dev`.
- **Production (`-d production`):**
  Uses domain `circuitverse.org` and bucket `circuitverse-images-prod`.

---

## 4. Secrets Management

Kamal 2 evaluates `.kamal/secrets` locally before connecting to target servers.

### Setting up secrets locally
1. Copy `.kamal/secrets.example` to `.kamal/secrets`:
   ```bash
   cp .kamal/secrets.example .kamal/secrets
   ```
2. Populate the required environment variables in your shell or `.env`:
   - `KAMAL_REGISTRY_PASSWORD` (GitHub Personal Access Token with package read permissions)
   - `SERVER_IP` (defaults to `13.127.94.74`)
   - `RAILS_MASTER_KEY` (or ensure `config/master.key` exists)
   - `POSTGRES_URL`
   - `SECRET_KEY_BASE`
   - `AWS_S3_ACCESS_KEY_ID` & `AWS_S3_SECRET_ACCESS_KEY`
   - `RECAPTCHA_SITE_KEY` & `RECAPTCHA_SECRET_KEY`
   - `BUGSNAG_API_KEY` (optional)

### Verifying Secrets & Configuration
Check the evaluated configuration locally without connecting to remote servers:
```bash
kamal config
# Or for a specific destination:
kamal config -d staging
```

View evaluated secrets:
```bash
kamal secrets print
```

---

## 5. Deployment Procedures

### Initial Server Bootstrap (`kamal setup`)
For a fresh server with Ubuntu and SSH access:
1. Ensure `circuitverse-production-2026.pem` has strict permissions (`chmod 600 circuitverse-production-2026.pem`). Kamal uses this key automatically for SSH connections to `ubuntu@13.127.94.74`.
2. Run:
   ```bash
   kamal setup -d staging
   ```
   This command installs Docker on the server, creates the `kamal` network, boots `kamal-proxy`, boots accessories, pushes environment secrets, and deploys the application containers.

### Upgrading an Existing Server from Kamal 1 (`kamal upgrade`)
If upgrading a server that was previously deployed using Kamal 1 (Traefik):
1. Kamal 2 provides an in-place upgrade command:
   ```bash
   kamal upgrade -d staging
   ```
   This stops and removes Traefik, sets up `kamal-proxy`, creates the new network, and reconnects running containers without data loss.

### Routine Deployment
When deploying updates from local machine:
```bash
kamal deploy
# Or with a destination:
kamal deploy -d staging
```

When images are built and pushed via CI/CD (GitHub Actions), use `--skip-push`:
```bash
kamal deploy --skip-push
```

### Automated CI/CD Deployment
The `.github/workflows/deploy.yml` workflow triggers automatically on push to `master`:
1. `docker-publish.yml` builds and pushes the image tagged with `${{ github.sha }}` and `:latest` to `ghcr.io`.
2. `deploy.yml` sets up Ruby 4.0.10, installs `kamal ~> 2.0`, initializes `.kamal/secrets`, and runs `kamal deploy --skip-push`.
3. Manual deployments can also be triggered via GitHub Actions `workflow_dispatch` with an optional destination input (`staging` or `production`).

---

## 6. Daily Operations & Troubleshooting

### Viewing Logs
```bash
# Web application logs
kamal app logs

# Sidekiq logs
kamal app logs -r sidekiq

# Follow live logs
kamal app logs -f

# kamal-proxy logs
kamal proxy logs

# Accessory logs
kamal accessory logs database
kamal accessory logs redis
```

### Running Commands on the Server
```bash
# Rails console
kamal app exec -i --reuse "bin/rails console"

# Database migration status
kamal app exec -i --reuse "bin/rails db:migrate:status"

# Run a bash shell inside the app container
kamal app exec -i --reuse "bash"
```

### Managing Accessories
```bash
# Boot all accessories
kamal accessory boot all

# Boot specific accessories
kamal accessory boot database
kamal accessory boot redis

# Reboot accessories (preserves persistent data volumes)
kamal accessory reboot database
kamal accessory reboot redis
```

### Managing Proxy
```bash
# Check proxy status
kamal proxy reboot
kamal proxy logs
```

### Rollback
To instantly rollback to a previous version:
```bash
kamal rollback <GIT_COMMIT_SHA>
```

### Releasing Locks
If a deployment was aborted and left a lock:
```bash
kamal lock status
kamal lock release
```
