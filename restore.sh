#!/bin/bash

BACKUP_DIR="/home/devops/Downloads/pg_backup"
BACKUP_FILE=$(ls -t $BACKUP_DIR/channel_partners_*.dump | head -n 1)

if [ ! -f "$BACKUP_FILE" ]; then
    echo "No backup file found in $BACKUP_DIR"
    exit 1
fi

PGPASSWORD='wertyutrewrt' pg_restore -h 12345678 -U channel_partners -d channel_partners -v "$BACKUP_FILE"
echo "Database restored successfully from $BACKUP_FILE!"


