# Security scan guide (Trivy)

This document explains how the Trivy workflow scans the project, where the reports are published, and how maintainers can reproduce the scan locally.

## What the workflow does

- Runs on pull requests, pushes to `master`, and manual dispatches.
- Builds the CircuitVerse Docker image with the required Dockerfile build arguments.
- Scans both the Docker image and repository filesystem with Trivy.
- Produces JSON and SARIF reports for image and filesystem scans.
- Uploads reports as workflow artifacts and uploads SARIF to GitHub Code Scanning when the event has permission.
- Comments a short vulnerability summary on same-repository pull requests.

The workflow is intentionally report-only for now: Trivy uses `exit-code: "0"` so existing vulnerabilities do not block unrelated pull requests while the project establishes a baseline. After the team triages current findings, the workflow can be tightened to fail on `CRITICAL,HIGH`.

## Local PowerShell run

From the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ./scripts/run-trivy.ps1
```

The script builds `circuitverse:local`, runs image and filesystem scans, and writes:

- `trivy-image.json`
- `trivy-image.sarif`
- `trivy-fs.json`
- `trivy-fs.sarif`

## Manual Trivy commands

Install Trivy, build the Docker image, and run the scans:

```powershell
docker build `
  --build-arg NON_ROOT_USER_ID=1000 `
  --build-arg NON_ROOT_GROUP_ID=1000 `
  --build-arg NON_ROOT_USERNAME=cvuser `
  --build-arg NON_ROOT_GROUPNAME=cvgroup `
  --build-arg OPERATING_SYSTEM=linux `
  -t circuitverse:local .

trivy image --severity CRITICAL,HIGH,MEDIUM --format json -o trivy-image.json circuitverse:local
trivy image --severity CRITICAL,HIGH,MEDIUM --format sarif -o trivy-image.sarif circuitverse:local
trivy fs --severity CRITICAL,HIGH,MEDIUM --format json -o trivy-fs.json .
trivy fs --severity CRITICAL,HIGH,MEDIUM --format sarif -o trivy-fs.sarif .
```

## Triage guidelines

1. `CRITICAL`: patch or mitigate immediately.
2. `HIGH`: triage quickly and open a follow-up issue or pull request.
3. `MEDIUM`: review and schedule in the next maintenance window.
4. `LOW`: document or accept when appropriate.

If a finding is a false positive, document the reason in the pull request and add a justified `.trivyignore` entry.