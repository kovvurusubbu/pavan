#!/bin/bash

HOST="IP_..."
PORT="9042"
USER="TEST"
PASS="HELLOWW123"
BACKUP_DIR="/root/backup/v2"

mkdir -p "$BACKUP_DIR"

echo "=== BACKUP STARTED ==="

###################################
# morders keyspace
###################################
declare -a MORDERS_TABLES=(
"vehicleorderscreated"
"travelorderscreated"
"vehicleordersbystatus"
"vehicleordersstatus"
"ordersbystatus"
"messages"
"offsetstore"
"orderscreated"
"ordersstatus"
"travelordersbystatus"
"snapshots"
"travelordersstatus"
"metadata"
"\"config\""
)

for t in "${MORDERS_TABLES[@]}"; do
    CLEAN_NAME=$(echo $t | tr -d '"')
    echo "Exporting morders.$CLEAN_NAME ..."
    cqlsh $HOST $PORT -u $USER -p $PASS \
      -e "COPY morders.$t TO '$BACKUP_DIR/morders_${CLEAN_NAME}.csv' WITH HEADER=TRUE;"
done


###################################
# menquiries keyspace
###################################
declare -a MENQ_TABLES=(
"travel_enquiry"
"vehicle_enquiry"
"messages"
"offsetstore"
"snapshots"
"metadata"
"\"config\""
)

for t in "${MENQ_TABLES[@]}"; do
    CLEAN_NAME=$(echo $t | tr -d '"')
    echo "Exporting menquiries.$CLEAN_NAME ..."
    cqlsh $HOST $PORT -u $USER -p $PASS \
      -e "COPY menquiries.$t TO '$BACKUP_DIR/menquiries_${CLEAN_NAME}.csv' WITH HEADER=TRUE;"
done


###################################
# policies keyspace
###################################
declare -a POLICIES_TABLES=(
"policycreated"
"snapshots"
"policystatus"
"metadata"
"messages"
"offsetstore"
"\"config\""
)

for t in "${POLICIES_TABLES[@]}"; do
    CLEAN_NAME=$(echo $t | tr -d '"')
    echo "Exporting policies.$CLEAN_NAME ..."
    cqlsh $HOST $PORT -u $USER -p $PASS \
      -e "COPY policies.$t TO '$BACKUP_DIR/policies_${CLEAN_NAME}.csv' WITH HEADER=TRUE;"
done

echo "=== BACKUP COMPLETED ==="
echo "Backups in: $BACKUP_DIR"
