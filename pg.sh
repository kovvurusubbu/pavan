#!/bin/bash
BACKUP_PATH="/home/devops/Downloads/pg_backup"
FILENAME="channel_partners_$(date +%Y%m%d).dump"
PGPASSWORD='ertyuiytre' pg_dump -h 1234567654 \
    -U channel_partners -d channel_partners -F c -b -v -f $BACKUP_PATH/$FILENAME
echo "Backup saved to $BACKUP_PATH/$FILENAME"