#!/bin/bash
BACKUP_PATH="/home/subbu/Desktop/pgg"
FILENAME="postgres_channel_tables_$(date +%Y%m%d).dump"

PGPASSWORD='3mxTtUQ2IC' pg_dump -h host_url \
    -U partners_staging \
    -d partners \
    -F c -b -v \
    -t cp_auth_master \
    -t cp_payment_details \
    -f "$BACKUP_PATH/$FILENAME"

echo "Backup saved to $BACKUP_PATH/$FILENAME"

