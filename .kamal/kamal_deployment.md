## Prerequisites

Before deploying, you need:

### On your local machine
- Ruby ≥ 3.1  
- Docker
- Kamal

  ```shell
  gem install kamal
  ```

### On the server
- Ubuntu server
- Docker installed
- Public IP address
- Ports 80 and 443 open
- Domain pointed to the server (e.g., `staging.circuitverse.org`)

## Server Configuration
Kamal reads the target server from:
```shell
SERVER_IP=<your_server_ip>
```

## Required Secrets
These secrets must be configured before deploying. You can provide them via environment variables or the Kamal secrets manager

| Variable                       | Purpose                         |
| ------------------------------ | ------------------------------- |
| `KAMAL_GHCR_REGISTRY_PASSWORD` | GitHub Container Registry login |
| `RAILS_MASTER_KEY`             | Rails encrypted credentials     |
| `POSTGRES_URL`                 | PostgreSQL database URL         |
| `AWS_S3_ACCESS_KEY_ID`         | Amazon S3 access                |
| `AWS_S3_SECRET_ACCESS_KEY`     | Amazon S3 secret                |
| `SECRET_KEY_BASE`              | Rails session encryption        |
| `RECAPTCHA_SITE_KEY`           | Spam protection                 |
| `RECAPTCHA_SECRET_KEY`         | Spam protection                 |
| `VAPID_PUBLIC_KEY`             | Web push notifications          |
| `VAPID_PRIVATE_KEY`            | Web push notifications          |

## How to deploy
From the project root:
```shell
kamal setup
```
Then deploy by running:
```shell
kamal deploy
```
If you discover a bad deploy, you can roll back a deployment (optional):
```shell
kamal rollback
```

## Troubleshooting
If you face issues during deployment, troubleshoot by checking logs:
```shell
kamal logs
```
