#!/bin/bash

set -e  # Exit on error
set -x  # Debug mode

echo "$(date) - Running backup" >> /home/bitnami/backup.log

SNAPSHOT_NAME="snapshot-$(date +%Y-%m-%d_%H-%M-%S)"

RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "http://localhost:9200/_snapshot/my_backup/$SNAPSHOT_NAME?wait_for_completion=true" \
  -H 'Content-Type: application/json' -d '{
    "indices": "*",
    "ignore_unavailable": true,
    "include_global_state": false
  }')

if [ "$RESPONSE" -eq 200 ]; then
  echo "$(date) - Backup successful: $SNAPSHOT_NAME" >> /home/bitnami/backup.log
else
  echo "$(date) - Backup failed with HTTP status: $RESPONSE" >> /home/bitnami/backup.log
  exit 1
fi
