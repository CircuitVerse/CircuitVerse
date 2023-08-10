#!/bin/bash

# PostgreSQL connection details
PG_HOST="db"
PG_PORT="5432"

# Function to check if PostgreSQL on port 5432 is up and running
check_postgres() {
  nc -z "$PG_HOST" "$PG_PORT" >/dev/null 2>&1
  return $?
}

# Wait for PostgreSQL to be up
echo "Waiting for PostgreSQL to be up..."

while ! check_postgres; do
  sleep 1
done

# Start web server
bin/dev