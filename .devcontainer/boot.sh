#!/bin/bash
# Fast no-op if DB is already healthy via compose healthcheck.
for _ in $(seq 1 15); do
  pg_isready -h db -p 5432 -U postgres >/dev/null 2>&1 && exit 0
  sleep 1
done
echo "DB not ready yet; bin/dev will retry on boot."
