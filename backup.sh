#!/bin/bash

# Backup location and date
BACKUP_PATH="/home/subbu/Desktop/pgg"
DATE=$(date +%Y%m%d)

# Database connection details
HOST="host"
USER="partners_staging"
DB="partners"
PASSWORD="UQ2IC"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_PATH"

# Backup cp_auth_master
PGPASSWORD="$PASSWORD" psql -h "$HOST" -U "$USER" -d "$DB" \
    -c "\COPY cp_auth_master TO '$BACKUP_PATH/cp_auth_master_$DATE.csv' WITH CSV HEADER"

# Backup cp_payment_details
PGPASSWORD="$PASSWORD" psql -h "$HOST" -U "$USER" -d "$DB" \
    -c "\COPY cp_payment_details TO '$BACKUP_PATH/cp_payment_details_$DATE.csv' WITH CSV HEADER"

echo "✅ CSV data backups completed and saved to $BACKUP_PATH"
