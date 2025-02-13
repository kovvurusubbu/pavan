#!/bin/bash

# MongoDB connection details
HOST="0.0.0.0.0"
PORT="22017"
USER="-----"
PASSWORD="-----"
AUTH_DB="test-product-catalog"
DB="test-product-catalog"
OUTPUT_DIR="/home/ksr/Documents/backup"

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"

# List of collections to back up
collections=(
  "GenderMappingMaster"
  "GroupHealthPremiumCalcMaster"
  "HDFCGroupHealthPremiumCalcMaster"
  "HDFCHealthPremiumCalcMaster"
  "HDFCHealthPremiumCalcMaster_Without_GST"
  "HealthConditionsMaster"
  "HospitalsPhotoUrl"
  "ICICIGroupHealthCalcPremiumMaster"
  "ICICIGroupHealthMatCalcPremiumMaster"
  "InsurerConfigMaster"

)

# Loop through collections and back them up
for collection in "${collections[@]}"; do
  echo "Backing up collection: $collection"
  mongodump --host "$HOST" --port "$PORT" -u "$USER" -p "$PASSWORD" --authenticationDatabase "$AUTH_DB" --db "$DB" --collection "$collection" --out "$OUTPUT_DIR"
  if [ $? -eq 0 ]; then
    echo "Successfully backed up collection: $collection"
  else
    echo "Failed to back up collection: $collection"
  fi
done

echo "Backup process completed."




chmod +x filenmae.sh
./filename.sh
