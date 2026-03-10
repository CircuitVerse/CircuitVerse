# Kamal 2.0 Deployment Guide for CircuitVerse

This guide covers how to deploy CircuitVerse to production using [Kamal 2.0](https://kamal-deploy.org/).

---

## Prerequisites

| Requirement    | Details                                                                                 |
| -------------- | --------------------------------------------------------------------------------------- |
| **Docker**     | Installed on your local machine ([Install Docker](https://docs.docker.com/get-docker/)) |
| **Kamal 2.0**  | `gem install kamal` (requires Ruby)                                                     |
| **Server**     | Ubuntu server with SSH access                                                           |
| **GHCR Token** | GitHub Container Registry personal access token with `write:packages` scope             |

---

## Quick Start

### 1. Install Kamal

```bash
gem install kamal
```

### 2. Configure Secrets

Set the required environment variables listed in `.kamal/secrets`:

```bash
export KAMAL_GHCR_REGISTRY_PASSWORD=<your-ghcr-token>
export RAILS_MASTER_KEY=<your-master-key>
export SECRET_KEY_BASE=<your-secret-key>
export POSTGRES_URL=<your-database-url>
export AWS_S3_ACCESS_KEY_ID=<your-aws-key>
export AWS_S3_SECRET_ACCESS_KEY=<your-aws-secret>
export RECAPTCHA_SITE_KEY=<your-recaptcha-site-key>
export RECAPTCHA_SECRET_KEY=<your-recaptcha-secret-key>
export SERVER_IP=<your-server-ip>
```

Or use `kamal envify` to generate a `.env` file from `.kamal/secrets`.

### 3. Bootstrap the Server

For a fresh server, run:

```bash
kamal server bootstrap
```

This installs Docker and prepares the server for deployments.

### 4. Deploy

```bash
kamal setup    # First-time setup (creates containers, proxy, etc.)
kamal deploy   # Subsequent deployments
```

---

## Common Commands

| Command                              | Description                     |
| ------------------------------------ | ------------------------------- |
| `kamal deploy`                       | Deploy the latest version       |
| `kamal redeploy`                     | Force a redeployment            |
| `kamal rollback <version>`           | Rollback to a previous version  |
| `kamal app logs`                     | View application logs           |
| `kamal app details`                  | Show running container details  |
| `kamal app exec 'bin/rails console'` | Open a Rails console            |
| `kamal proxy reboot`                 | Reboot the Kamal proxy          |
| `kamal lock release`                 | Release a stuck deployment lock |

---

## Configuration Files

| File                                | Purpose                                |
| ----------------------------------- | -------------------------------------- |
| `config/deploy.yml`                 | Main Kamal deployment configuration    |
| `.kamal/secrets`                    | Secret environment variable references |
| `.kamal/hooks/`                     | Deployment lifecycle hook scripts      |
| `Dockerfile.production`             | Production Docker image definition     |
| `config/environments/production.rb` | Rails production settings              |

---

## Secrets Management

Secrets are managed via `.kamal/secrets`. **Never commit actual secret values.**

**Recommended approaches:**

- **CI/CD:** Set secrets as repository/environment secrets in GitHub Actions
- **Local:** Export variables in your shell profile or use a `.env` file (gitignored)
- **kamal envify:** Run `kamal envify` to populate secrets from your environment

---

## Deployment Hooks

Kamal runs hook scripts at various stages of deployment. Sample hooks are provided in `.kamal/hooks/`:

| Hook                   | When it runs                   |
| ---------------------- | ------------------------------ |
| `pre-deploy.sample`    | Before deploying containers    |
| `pre-app-boot.sample`  | Before the app container boots |
| `post-app-boot.sample` | After the app container boots  |
| `post-deploy.sample`   | After deployment completes     |

**To activate a hook:** Remove the `.sample` extension and ensure it's executable:

```bash
cp .kamal/hooks/pre-deploy.sample .kamal/hooks/pre-deploy
chmod +x .kamal/hooks/pre-deploy
```

---

## Troubleshooting

### Deploy hangs or times out

```bash
kamal lock release    # Release stuck lock
kamal deploy          # Retry
```

### Container won't start

```bash
kamal app logs        # Check application logs
kamal app details     # Check container status
```

### Health check failing

- Verify the app responds on port 3000 at `/up`
- Check `config/deploy.yml` healthcheck settings
- Increase `max_attempts` if the app takes longer to boot

### SSH connection issues

- Verify `ssh.user` in `config/deploy.yml` matches your server user
- Ensure your SSH key is added to the server
- Test manually: `ssh ubuntu@<SERVER_IP>`
