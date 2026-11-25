#!/bin/sh
set -e

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PG_FILENAME="circuitverse_pg_${TIMESTAMP}.dump"
REDIS_FILENAME="circuitverse_redis_${TIMESTAMP}.rdb"
PG_TMP="/tmp/${PG_FILENAME}"
REDIS_TMP="/tmp/${REDIS_FILENAME}"

echo "[$(date)] Starting backup..."

# PostgreSQL backup
echo "[$(date)] Backing up PostgreSQL..."
pg_dump -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Fc -f "$PG_TMP"
aws s3 cp "$PG_TMP" "s3://${S3_BUCKET}/${S3_PREFIX}${PG_FILENAME}" --region "$S3_REGION"
rm -f "$PG_TMP"

# Redis backup
echo "[$(date)] Backing up Redis..."
# Trigger BGSAVE
redis-cli -h redis -p 6379 BGSAVE > /dev/null
# Wait for background save to complete
LAST_SAVE=$(redis-cli -h redis -p 6379 LASTSAVE)
while [ "$(redis-cli -h redis -p 6379 LASTSAVE)" = "$LAST_SAVE" ]; do
  sleep 1
done
# Copy RDB from redis container via docker
docker cp circuitverse-redis:/data/dump.rdb "$REDIS_TMP" 2>/dev/null || {
  # Fallback: redis-cli --rdb
  redis-cli -h redis -p 6379 --rdb "$REDIS_TMP"
}
aws s3 cp "$REDIS_TMP" "s3://${S3_BUCKET}/${S3_PREFIX}${REDIS_FILENAME}" --region "$S3_REGION"
rm -f "$REDIS_TMP"

# Delete backups older than 30 days
echo "[$(date)] Cleaning old backups..."
aws s3 ls "s3://${S3_BUCKET}/${S3_PREFIX}" --region "$S3_REGION" | while read -r line; do
  FILE_DATE=$(echo "$line" | awk '{print $1}')
  FILE_NAME=$(echo "$line" | awk '{print $4}')
  if [ -n "$FILE_NAME" ] && [ "$FILE_NAME" != "PRE" ]; then
    FILE_EPOCH=$(date -d "$FILE_DATE" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$FILE_DATE" +%s 2>/dev/null)
    CUTOFF_EPOCH=$(date -d "30 days ago" +%s 2>/dev/null || date -j -v-30d +%s 2>/dev/null)
    if [ "$FILE_EPOCH" -lt "$CUTOFF_EPOCH" ]; then
      aws s3 rm "s3://${S3_BUCKET}/${S3_PREFIX}${FILE_NAME}" --region "$S3_REGION"
      echo "[$(date)] Deleted old backup: $FILE_NAME"
    fi
  fi
done

echo "[$(date)] Backup complete"