#!/bin/bash

BACKUP_FILE="/home/subbu/Desktop/pgg/postgres_channel_tables_$(date +%Y%m%d).dump"
PGPASSWORD='MyNewSecurePass123' pg_restore -h 172.29.0.2 -U superadmin -d postgres -v $BACKUP_FILE
echo "Database restored successfully!"